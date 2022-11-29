//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IFactoryManager.sol";
import "../interfaces/IAgent.sol";
import "../interfaces/IUCV.sol";
import "../interfaces/IPayrollManager.sol";

import "./BaseVerify.sol";
import "../utils/BytesUtils.sol";
import "../tokens/InkBadgeERC20.sol";

import "../libraries/defined/DutyID.sol";
import "../libraries/defined/FactoryKeyTypeID.sol";
import "hardhat/console.sol";

error MsgSenderIsNotAgent(address msgSender);
error MsgSenderIsNotCommittee(address msgSender);
error AgentCanBeCreatedOnlyOnceInDAO(bytes32 agentsKey);
error FlowIsNotSupport(uint256 flowIndex, bytes32 wantedFlowID);
error DeployFailuer(bytes32 factoryKey);

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;
    using BytesUtils for bytes;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    string internal constant EXPIRATION_KEY = "Expiration";

    /// @notice store the connection between different committee in a flow
    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
    }

    /// @notice BaseDAO initial data, when create dao,
    /// these data are necessary for creating the DAO instance.
    /// @param name DAO name
    /// @param describe DAO's description
    /// @param mds DAO's meta data
    /// @param govTokenAddr DAO's governance token
    /// @param govTokenAmountRequirement base requirement token amount for createing the DAO
    /// @param stakingAddr DAO's staking engine address
    /// @param flows operate flows of the DAO
    /// @param badgeName the badge name of the DAO
    /// @param badgeTotal how many badges in the DAO
    /// @param daoLogo dao's logo image path on internet or IFPS/AR/
    /// @param minPledgeRequired minimal token needed to pledge
    /// @param minEffectiveVotes minimal effective votes
    /// @param minEffectiveVoteWallets minimal effective vote wallets
    /// @param defaultFlowIDIndex three base flows [0] = 0x00...0, [1] = 0x00..1, [2] = 0x00..2
    /// @param proposalHandlerKey used to create proposal handler
    struct BaseDAOInitData {
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        string badgeName;
        uint256 badgeTotal;
        // address badgeAddress;
        string daoLogo;
        uint256 minPledgeRequired;
        uint256 minEffectiveVotes;
        uint256 minEffectiveVoteWallets;
        bytes32 factoryManagerKey;
        uint256 defaultFlowIDIndex;
        FlowInfo[] flows;
        bytes32 proposalHandlerKey;
        bytes32 inkBadgeKey;
        address badge;
        bytes[] committees;
    }

    // variables ////////////////////////////////////////////////////////////////////////
    /// @notice limit the vote flow steps at most 10 steps
    uint256 public constant MAX_STEP_NUM = 10;

    bytes32 internal constant _SENTINEL_ID =
        0x0000000000000000000000000000000000000000000000000000000000000001;

    /// @dev maintain three basic steps(The Board, The Public+The Board, The Public)
    bytes32[] private _defaultFlows;

    /// @notice the one who created the DAO
    address private _ownerAddress;

    /// @notice DAO name;
    string private _name;

    /// @notice description of the dao
    string private _describe;

    /// @notice governance token
    IERC20 private _govToken;

    /// @notice ？？
    uint256 private _govTokenAmountRequirement;

    /// @notice staking engine address
    address private _stakingAddr;

    address private _badge;

    /// @notice global config manager addres
    /// @dev get contract implementation through the key
    address private _configManager;

    address private _factoryAddress;
    uint256 private _minPledgeRequired;
    uint256 private _minEffectiveVotes;
    uint256 private _minEffectiveVoteWallets;
    ///@dev BoardOnly=0, PublicAndBoard=1, Public Only=2
    uint256 private _defaultFlowIDIndex = 0;

    address private _proposalHandlerAddress;

    /// @dev stored proposal
    /// proposalID=>ProposalProgress
    mapping(bytes32 => ProposalProgress) internal _proposalInfo;

    /// @dev key is dutyID
    /// find duty members according to dutyID,
    mapping(bytes32 => EnumerableSet.AddressSet) private _dutyMembers;

    /// @notice how many dutyIDs the EOA address have in the DAO
    /// @dev once the _dutyCounts become 0, it should be removed from the DAO
    mapping(address => uint256) private _dutyCounts;

    /// @notice anyone has one duty will be stored here.
    EnumerableSet.AddressSet private _daoMembersWithDuties;

    /// @dev for verify the deployed contracts by key
    mapping(bytes32 => address) private _deployedContractdByKey;

    // process category flow ID => (stepID => step info)
    mapping(bytes32 => mapping(bytes32 => StepLinkInfo)) internal _flowSteps;

    /// for test
    EnumerableSet.Bytes32Set internal _proposalsArray;

    CommitteeInfo[] internal _committees;

    /// @dev agentsKey=>agentDeployedAddress;
    mapping(bytes32 => address) private _agents;

    EnumerableSet.Bytes32Set private _agentKeys;

    EnumerableSet.AddressSet private _ucvSet;

    modifier ensureGovEnough() {
        require(
            _govToken.balanceOf(_ownerAddress) > _govTokenAmountRequirement,
            "admin's gov not enough"
        );
        _;
    }

    modifier onlyAgent() {
        address[] memory agentAddress;
        bool exist = false;
        // console.log("compare agent:");
        for (uint256 i = 0; i < _agentKeys.length(); i++) {
            console.log(_msgSender());
            console.log(_agents[_agentKeys.at(i)]);
            if (_msgSender() == _agents[_agentKeys.at(i)]) {
                exist = true;
                break;
            }
        }
        if (!exist) {
            revert MsgSenderIsNotAgent(_msgSender());
        }
        _;
    }

    modifier onlyCommittee() {
        bool exist = false;
        for (uint256 i = 0; i < _committees.length; i++) {
            if (_msgSender() == _committees[i].committee) {
                exist = true;
                break;
            }
        }
        if (!exist) {
            revert MsgSenderIsNotCommittee(_msgSender());
        }
        _;
    }

    // test functins
    function getProposalIDByIndex(uint256 index)
        external
        view
        returns (bytes32 _proposalID)
    {
        _proposalID = _proposalsArray.at(index);
    }

    function getMinPledgeRequired() external view returns (uint256) {
        return _minPledgeRequired;
    }

    /// @inheritdoc IProposalHandler
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        address proposer,
        bytes calldata data
    ) public override returns (bytes32 proposalID) {
        /* EnsureGovEnough */

        proposalID = IProposalHandler(_proposalHandlerAddress).newProposal(
            proposal,
            commit,
            proposer,
            data
        );

        /// @dev create agent and check parameters
        _setupAgents(proposalID, proposal.agents, data);

        _setupProposalFlow(proposalID, proposal.agents);

        /// for test
        _proposalsArray.add(proposalID);

        // emit event
        emit NewProposal(
            proposalID,
            proposal.metadata,
            proposal.kvData,
            block.timestamp,
            proposer
        );
    }

    function getBadge() external view returns (address badge) {
        badge = _badge;
    }

    function _setupProposalFlow(bytes32 proposalID, bytes32[] memory agents)
        internal
    {
        bytes32 flowID = _getProposalFlow(proposalID);

        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[flowID];

        console.log("flowID --*************** ");
        console.logBytes32(flowID);

        bytes32 firstStep = steps[_SENTINEL_ID].nextStep;
        if (firstStep == bytes32(0x0)) {
            revert SystemError();
        }

        ProposalProgress storage info = _proposalInfo[proposalID];
        info.proposalID = proposalID;
        info.flowID = flowID;
        // decicde next step and which commit is handle the process
        info.nextCommittee.step = firstStep;
        info.nextCommittee.committee = steps[firstStep].committee;
        info.lastOperationTimestamp = block.timestamp;
        info.agents = agents;
    }

    /// @inheritdoc IDAO
    function getDAOCommittees()
        external
        view
        override
        returns (DAOCommitteeWithDuty[] memory committeeDuties)
    {
        uint256 len = _committees.length;
        committeeDuties = new DAOCommitteeWithDuty[](len);

        for (uint256 i = 0; i < len; i++) {
            committeeDuties[i].committee = _committees[i].committee;
            committeeDuties[i].committeeName = _committees[i].name;
            if (_committees[i].dutyIDs.length > 0) {
                bytes32[] memory dutyArray = abi.decode(
                    _committees[i].dutyIDs,
                    (bytes32[])
                );
                committeeDuties[i].duties = dutyArray;
            }
        }
    }

    /// @inheritdoc IProposalHandler
    function getTallyVoteRules(bytes32 proposalID)
        external
        view
        override
        returns (
            uint256 minAgreeRatio,
            uint256 minEffectiveVotes,
            uint256 minEffectiveWallets
        )
    {
        minAgreeRatio = 5 * 1e17;
        minEffectiveVotes = _minEffectiveVotes;
        minEffectiveWallets = _minEffectiveVoteWallets;

        (, uint256 minVotes, uint256 minWallets) = IProposalHandler(
            _proposalHandlerAddress
        ).getTallyVoteRules(proposalID);

        if (minVotes > 0) {
            minEffectiveVotes = minVotes;
        }

        if (minWallets > 0) {
            minEffectiveWallets = minWallets;
        }
    }

    function getDAOTallyVoteRules()
        external
        view
        returns (
            uint256 minAgreeRatio,
            uint256 minEffectiveVotes,
            uint256 minEffectiveWallets
        )
    {
        minAgreeRatio = 5 * 1e17;
        minEffectiveVotes = _minEffectiveVotes;
        minEffectiveWallets = _minEffectiveVoteWallets;
    }

    function getSupportedFlow() external view returns (bytes32[] memory flows) {
        flows = new bytes32[](_defaultFlows.length - _defaultFlowIDIndex);
        uint256 startIndex = 0;
        for (uint256 i = _defaultFlowIDIndex; i < _defaultFlows.length; i++) {
            flows[startIndex] = _defaultFlows[i];
            startIndex++;
        }
    }

    function _init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual returns (bytes memory callbackEvent) {
        super.init(config_);

        console.log(
            "PROPOSER ##### ############################################################"
        );
        console.logBytes32(keccak256("dutyID.PROPOSER"));
        /// board vote
        _defaultFlows.push(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
        /// public vote and board vote
        _defaultFlows.push(
            0x0000000000000000000000000000000000000000000000000000000000000001
        );
        /// public vote
        _defaultFlows.push(
            0x0000000000000000000000000000000000000000000000000000000000000002
        );

        // init data
        BaseDAOInitData memory initData = abi.decode(data, (BaseDAOInitData));
        _ownerAddress = admin_;
        _name = initData.name;
        _describe = initData.describe;
        _govToken = initData.govTokenAddr;
        _govTokenAmountRequirement = initData.govTokenAmountRequirement;
        _stakingAddr = initData.stakingAddr;
        _minEffectiveVotes = initData.minEffectiveVotes;
        _minEffectiveVoteWallets = initData.minEffectiveVoteWallets;
        _minPledgeRequired = initData.minPledgeRequired;
        _defaultFlowIDIndex = initData.defaultFlowIDIndex;

        (, bytes memory factoryAddressBytes) = configManager.getKV(
            initData.factoryManagerKey
        );
        _factoryAddress = factoryAddressBytes.toAddress();

        _setupCommittees(initData.committees);

        // _metadata._init();
        // _metadata._setBytesSlice(initData.mds);
        // require(initData.flows.length != 0, "no flow set");

        for (uint256 i = 0; i < initData.flows.length; i++) {
            _setFlowStep(initData.flows[i]);
        }

        if (initData.badge != address(0)) {
            _badge = initData.badge;
        } else {
            // create new badge
            if (bytes(initData.badgeName).length != 0) {
                _badge = _createBadge(
                    initData.inkBadgeKey,
                    initData.badgeName,
                    initData.badgeTotal,
                    admin_
                );
                emit NewBadgeCreated(
                    _badge,
                    initData.name,
                    initData.badgeTotal
                );
            }
        }

        _proposalHandlerAddress = _deployByFactoryKey(
            false,
            FactoryKeyTypeID.PROPOSAL_HANDLER_TYPE_ID,
            initData.proposalHandlerKey,
            ""
        );

        // initial dutyID
        _addDuty(admin_, DutyID.PROPOSER);
        _addDuty(admin_, DutyID.VOTER);

        emit NewDAOCreated(
            admin_,
            address(initData.govTokenAddr),
            _name,
            IERC20Metadata(address(initData.govTokenAddr)).name(),
            initData.daoLogo,
            block.timestamp
        );
    }

    /// @inheritdoc IDutyControl
    function addDuty(address account, bytes32 dutyID)
        external
        override
        onlyAgent
    {
        _addDuty(account, dutyID);
    }

    function _addDuty(address account, bytes32 dutyID) internal {
        if (!_dutyMembers[dutyID].contains(account)) {
            emit AddDAOMemberDuty(account, dutyID);

            _dutyMembers[dutyID].add(account);
            _dutyCounts[account] += 1;

            if (!_daoMembersWithDuties.contains(account)) {
                _daoMembersWithDuties.add(account);
            }
        }
    }

    function getDeployedContractByKey(bytes32 key)
        external
        view
        returns (address deployedAddress)
    {
        deployedAddress = _deployedContractdByKey[key];
    }

    /// @inheritdoc IDutyControl
    function remmoveDuty(address account, bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function addUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function removeUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function hasDuty(address account, bytes32 dutyID)
        external
        view
        override
        returns (bool exist)
    {
        exist = _hasDuty(account, dutyID);
    }

    function _hasDuty(address account, bytes32 dutyID)
        internal
        view
        returns (bool exist)
    {
        exist = _dutyMembers[dutyID].contains(account);
    }

    /// @inheritdoc IDutyControl
    function getDutyOwners(bytes32 dutyID)
        external
        view
        override
        returns (uint256 owners)
    {
        owners = _dutyMembers[dutyID].length();
    }

    /// @inheritdoc IDutyControl
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        view
        override
        returns (address addr)
    {
        addr = _dutyMembers[dutyID].at(index);
    }

    // which proposal decide the latest key item;
    /// @inheritdoc IProposalHandler
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 proposalID)
    {
        return
            IProposalHandler(_proposalHandlerAddress).getTopicKeyProposal(
                topicID,
                key
            );
    }

    /// @inheritdoc IProposalHandler
    function getTopicMetadata(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        return
            IProposalHandler(_proposalHandlerAddress).getTopicMetadata(
                topicID,
                key
            );
    }

    /// @inheritdoc IProposalHandler
    function getTopicInfo(bytes32 topicID)
        external
        view
        override
        returns (Topic memory topic)
    {
        topic = IProposalHandler(_proposalHandlerAddress).getTopicInfo(topicID);
    }

    /// @inheritdoc IProposalHandler
    function getProposalSummary(bytes32 proposalID)
        external
        view
        override
        returns (ProposalSummary memory proposal)
    {
        proposal = IProposalHandler(_proposalHandlerAddress).getProposalSummary(
                proposalID
            );
    }

    /// @inheritdoc IProposalHandler
    function getProposalMetadata(bytes32 proposalID, string memory key)
        public
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        return
            IProposalHandler(_proposalHandlerAddress).getProposalMetadata(
                proposalID,
                key
            );
    }

    /// @inheritdoc IProposalHandler
    function getTopicKVdata(bytes32 topicID, string memory key)
        public
        view
        override
        returns (
            // ExistTopic(topicID)
            bytes32 typeID,
            bytes memory data
        )
    {
        return
            IProposalHandler(_proposalHandlerAddress).getTopicKVdata(
                topicID,
                key
            );
    }

    /// @inheritdoc IProposalHandler
    function getProposalKvData(bytes32 proposalID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        return
            IProposalHandler(_proposalHandlerAddress).getProposalKvData(
                proposalID,
                key
            );
    }

    /// @inheritdoc IProposalHandler
    function getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) external view override returns (string[] memory keys) {
        return
            IProposalHandler(_proposalHandlerAddress).getProposalKvDataKeys(
                proposalID,
                startKey,
                pageSize
            );
    }

    /// @inheritdoc IProposalHandler
    function getProposalTopic(bytes32 proposalID)
        external
        view
        override
        returns (bytes32 topicID)
    {
        return
            IProposalHandler(_proposalHandlerAddress).getProposalTopic(
                proposalID
            );
    }

    /// @inheritdoc IProposalHandler
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external override {
        _decideProposal(proposalID, msg.sender, agree, data);
    }

    function execProposalMessage(bytes32 proposalID, bytes memory messages)
        external
        override
    {
        require(_ownerAddress == _msgSender(), "not dao admin");

        IProposalHandler(_proposalHandlerAddress).execProposalMessage(
            proposalID,
            messages
        );
    }

    function flushTopicIndex(bytes32 topicID, uint256 operateNum)
        external
        override
    {
        IProposalHandler(_proposalHandlerAddress).flushTopicIndex(
            topicID,
            operateNum
        );
    }

    /// @inheritdoc IAgentHandler
    function getAgentIDAddr(bytes32 agentID)
        external
        override
        returns (address agentAddr)
    {}

    /// @inheritdoc IAgentHandler
    function continueExec(bytes32 proposalID, uint256 agentNum)
        external
        override
    {}

    /// @inheritdoc IAgentHandler
    function setAgentFlowID(bytes32 agentID, bytes32 flowID)
        external
        override
    {}

    /// @inheritdoc IAgentHandler
    function getAgentFlowID(bytes32 agentID)
        external
        override
        returns (bytes32 flowID)
    {
        flowID = _getAgentFlowID(agentID);
    }

    function _getAgentFlowID(bytes32 agentID)
        internal
        returns (bytes32 flowID)
    {
        address agentAddress = _agents[agentID];
        flowID = IAgent(agentAddress).getAgentFlow();
    }

    /// @inheritdoc IAgentHandler
    function execTx(TxInfo[] memory txs) external override {}

    function getFlowSteps(bytes32 flowID)
        external
        view
        override
        returns (CommitteeInfo[] memory infos)
    {
        infos = new CommitteeInfo[](MAX_STEP_NUM);
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[flowID];

        bytes32 currentStep = steps[_SENTINEL_ID].nextStep;
        uint256 idx = 0;
        while (
            idx < MAX_STEP_NUM &&
            currentStep != bytes32(0x0) &&
            currentStep != _SENTINEL_ID
        ) {
            infos[idx].step = currentStep;
            infos[idx].committee = steps[currentStep].committee;
            // infos[idx].name = IMetadata(infos[idx].committee).name();
            currentStep = steps[currentStep].nextStep;
            idx++;
        }

        assembly {
            mstore(infos, idx)
        }

        return infos;
    }

    function setupCommittee(
        string memory name,
        bytes32 deployKey,
        bytes memory dutyIDs
    ) external override onlyAgent {
        _deployCommittees(name, deployKey, dutyIDs);
    }

    //////////////////// internal

    function _setupCommittees(bytes[] memory committees) internal {
        for (uint256 i = 0; i < committees.length; i++) {
            (string memory name, bytes32 deployKey, bytes memory dutyIDs) = abi
                .decode(committees[i], (string, bytes32, bytes));
            _deployCommittees(name, deployKey, dutyIDs);
        }
    }

    function _deployCommittees(
        string memory name,
        bytes32 deployKey,
        bytes memory dutyIDBytes
    ) internal returns (address committeeAddr) {
        bytes memory initData = abi.encode(name, dutyIDBytes);

        address committeeAddress = _deployByFactoryKey(
            false,
            FactoryKeyTypeID.COMMITTEE_TYPE_ID,
            deployKey,
            initData
        );
        // // valid typeID
        // address committeeAddress = turnBytesToAddress(committeeAddressBytes);
        // console.log("committee address:", committeeAddress);
        // Deploy committee
        // require(
        //     ICommittee(committeeAddress).supportsInterface(
        //         type(ICommittee).interfaceId
        //     ),
        //     "committee addr not support ICommittee"
        // );
        _addIntoCurrentCommittee(committeeAddress, name, dutyIDBytes);
        committeeAddr = committeeAddress;
    }

    function _setupAgents(
        bytes32 proposalID,
        bytes32[] memory agents,
        bytes memory initData
    ) internal {
        for (uint256 i = 0; i < agents.length; i++) {
            if (
                agents[i] !=
                0x0000000000000000000000000000000000000000000000000000000000000000
            ) {
                address existAgents = _agents[agents[i]];
                if (
                    existAgents != address(0) &&
                    IAgent(existAgents).isExecuted() == true &&
                    IAgent(existAgents).isUniqueInDAO() == true
                ) {
                    revert AgentCanBeCreatedOnlyOnceInDAO(agents[i]);
                }

                _agentKeys.add(agents[i]);
                address agentContractAddress = _deployByFactoryKey(
                    false,
                    FactoryKeyTypeID.AGENT_TYPE_ID,
                    agents[i],
                    initData
                );

                if (agentContractAddress != address(0)) {
                    IAgent(agentContractAddress).initAgent(address(this));
                    bool isGoodToExecute = IAgent(agentContractAddress).preExec(
                        proposalID
                    );

                    if (!isGoodToExecute) {
                        revert AgentCannotBeExecute();
                    }

                    _agents[agents[i]] = agentContractAddress;
                } else {
                    revert GenerateContractByKeyFailure();
                }
            }
        }
    }

    function getProposalFlow(bytes32 proposalID)
        external
        view
        override
        returns (bytes32 flowID)
    {
        flowID = _getProposalFlow(proposalID);
    }

    function _getProposalFlow(bytes32 proposalID)
        internal
        view
        returns (bytes32 flowID)
    {
        // require(
        //     flowIndex >= _defaultFlowIDIndex,
        //     "flow should be more open than default flow"
        // );
        // require(flowIndex < _defaultFlows.length, "flow is not support");

        bytes32 proposalFlowID = IProposalHandler(_proposalHandlerAddress)
            .getProposalFlow(proposalID);
        console.log("proposal flow:");
        console.logBytes32(proposalFlowID);
        if (
            proposalFlowID ==
            0x0000000000000000000000000000000000000000000000000000000000000004
        ) {
            flowID = _defaultFlows[_defaultFlowIDIndex];
        } else {
            bool support = false;
            for (
                uint256 i = _defaultFlowIDIndex;
                i < _defaultFlows.length;
                i++
            ) {
                if (_defaultFlows[i] == proposalFlowID) {
                    support = true;
                    break;
                }
            }
            if (support) {
                flowID = proposalFlowID;
            } else {
                revert FlowIsNotSupport(_defaultFlowIDIndex, proposalFlowID);
            }
        }
    }

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        addr = abi.decode(byteAddress, (address));
    }

    function getNextVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        returns (CommitteeInfo memory committeeInfo)
    {
        ProposalProgress storage info = _proposalInfo[proposalID];
        committeeInfo = info.nextCommittee;
    }

    function getVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        override
        returns (address committee, bytes32 step)
    {
        ProposalProgress storage info = _proposalInfo[proposalID];
        committee = info.nextCommittee.committee;
        step = info.nextCommittee.step;
    }

    /// @dev verify if the committee is the next committee
    function _isNextCommittee(bytes32 proposalID, address committee)
        internal
        view
        returns (bool)
    {
        address nextCommittee = _proposalInfo[proposalID]
            .nextCommittee
            .committee;
        console.log("next committee:", nextCommittee);

        if (nextCommittee == address(0x0)) {
            return false;
        }

        return nextCommittee == committee;
    }

    function _appendFinishStep(ProposalProgress storage info) internal {
        CommitteeInfo storage committeeInfo = info.committees.push();
        committeeInfo.committee = info.nextCommittee.committee;
        committeeInfo.step = info.nextCommittee.step;
        info.lastOperationTimestamp = block.timestamp;
    }

    function _deployByFactoryKey(
        bool randomSalt,
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) internal returns (address deployedAddress) {
        if (
            randomSalt == false &&
            _deployedContractdByKey[contractKey] != address(0)
        ) {
            // deploy only once
            return _deployedContractdByKey[contractKey];
        }

        bytes memory deployCall = abi.encodeWithSignature(
            "deploy(bool,bytes32,bytes32,bytes)",
            randomSalt,
            typeID,
            contractKey,
            initData
        );

        (bool _success, bytes memory _returnedBytes) = address(_factoryAddress)
            .call(deployCall);

        if (_success) {
            deployedAddress = turnBytesToAddress(_returnedBytes);
            if (randomSalt == false) {
                _deployedContractdByKey[contractKey] = deployedAddress;
            }
        } else {
            revert DeployFailuer(contractKey);
            // console.log("test turn turn bytes 32 ", deployedAddress);
            // console.log("to address ", _returnedBytes.toAddress());
        }
    }

    function deployByKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) external override returns (address deployedAddress) {
        return _deployByFactoryKey(false, typeID, contractKey, initData);
    }

    function _execFinish(ProposalProgress storage info, bool agree) internal {
        require(info.nextCommittee.committee == address(0x0), "can't finish");
        // emit EDecideProposal(info.proposalID, agree);
        console.log("exec finished:", agree);

        if (agree == false) {
            emit ProposalDecide(
                address(this),
                info.proposalID,
                agree,
                bytes32(0x0),
                block.timestamp
            );
            return;
        }

        bytes32[] memory agents = info.agents;
        if (agree == true) {
            // execute agent
            for (uint256 i = 0; i < agents.length; i++) {
                if (
                    agents[i] !=
                    0x0000000000000000000000000000000000000000000000000000000000000000
                ) {
                    address agentAddress = _agents[agents[i]];
                    IAgent(agentAddress).exec(info.proposalID);
                }
            }
        }

        emit ProposalDecide(
            address(this),
            info.proposalID,
            agree,
            IProposalHandler(_proposalHandlerAddress).getProposalTopic(
                info.proposalID
            ),
            block.timestamp
        );
    }

    function _setNextStep(ProposalProgress storage info, bool breakFlow)
        internal
    {
        if (!breakFlow) {
            bytes32 flowID = info.flowID;

            console.log("flow ID ");
            console.logBytes32(flowID);

            StepLinkInfo storage nowStep = _flowSteps[flowID][
                info.nextCommittee.step
            ];

            info.nextCommittee.step = nowStep.nextStep;
            info.nextCommittee.committee = _flowSteps[flowID][nowStep.nextStep]
                .committee;
        } else {
            info.nextCommittee.step = bytes32(0x0);
            info.nextCommittee.committee = address(0x0);
        }
    }

    function setupFlowInfo(FlowInfo memory flow) external override onlyAgent {
        _setFlowStep(flow);
    }

    function setupUCV(address ucv, address ucvManager)
        external
        override
        onlyAgent
    {
        IUCVManager(ucvManager).setUCV(ucv);
    }

    function _setFlowStep(FlowInfo memory flow) internal {
        // _factoryAddress;
        require(flow.committees.length < MAX_STEP_NUM, "too many steps");
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            flow.flowID
        ];

        // init sentinel.
        steps[_SENTINEL_ID].nextStep = flow.committees[0].step;
        if (flow.committees[0].step != 0x00) {

            for (uint256 j = 0; j < flow.committees.length; j++) {

                CommitteeCreateInfo memory committeeInfo = flow.committees[j];
                require(
                    committeeInfo.step != bytes32(0x0) &&
                        committeeInfo.step != _SENTINEL_ID,
                    "step empty"
                );

                address deployedAddress = _deployCommittees(
                    committeeInfo.committeeName,
                    committeeInfo.addressConfigKey,
                    committeeInfo.dutyIDs
                );
                steps[committeeInfo.step].committee = deployedAddress;
                // link next committee
                if (j < flow.committees.length - 1) {
                    steps[committeeInfo.step].nextStep = flow
                        .committees[j + 1]
                        .step;
                } else {
                    steps[committeeInfo.step].nextStep = bytes32(0x0);
                }
            }
        } else {
            console.log(
                "no action required #############################################################################################################################################################################################################################################################################################################################################################################################################################"
            );
        }
    }

    function _addIntoCurrentCommittee(
        address committeeAddress,
        string memory committeeName,
        bytes memory dutyIDs
    ) internal {
        bool exist = false;
        for (uint256 i = 0; i < _committees.length; i++) {
            if (_committees[i].committee == committeeAddress) {
                exist = true;
                break;
            }
        }

        if (!exist) {
            CommitteeInfo memory c;
            c.committee = committeeAddress;
            c.name = committeeName;
            c.dutyIDs = dutyIDs;
            _committees.push(c);
        }
    }

    function _decideProposal(
        bytes32 proposalID,
        address committee,
        bool agree,
        bytes memory data
    ) internal {
        ProposalProgress storage info = _proposalInfo[proposalID];
        require(info.proposalID == proposalID, "proposal err");
        // why need to verify the next committee...
        // require(_isNextCommittee (proposalID, committee), "committee err");

        _appendFinishStep(info);
        _setNextStep(info, !agree);

        console.log("next committee", info.nextCommittee.committee);
        if (info.nextCommittee.committee == address(0x0)) {
            IProposalHandler(_proposalHandlerAddress).decideProposal(
                info.proposalID,
                agree,
                ""
            );
            _execFinish(info, agree);
        }
        /*
        if !flowHandler.hasNextFlow(proposalID) { 
            flowHandler.moveToNextFlow(proposalID)
        } else {
            flowhandler.flowFinished()
            ProposalHandler.decide()
        }
        */
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IDAO).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    function hasDAOBadges(address account)
        external
        view
        override
        returns (bool hasBadges)
    {
        if (_badge == address(0)) {
            // require no badges
            return true;
        }
        if (IERC20(_badge).balanceOf(account) > 0) {
            return true;
        }

        return false;
    }

    /// @notice verify if the account could vote
    /// @dev if dao dao require the badeges to vote or enought pledged tokens
    function allowToVote(address account)
        external
        view
        override
        returns (bool isAllow)
    {
        isAllow = false;
        if (_badge != address(0)) {
            isAllow = IERC20(_badge).balanceOf(account) > 0;
        } else {
            isAllow = true;
        }
    }

    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external override {}

    /// @inheritdoc IProcessHandler
    function getVoteExpirationTime(bytes32 proposalID)
        external
        view
        override
        returns (uint256 expiration)
    {
        (, bytes memory data) = IProposalHandler(_proposalHandlerAddress)
            .getProposalMetadata(proposalID, EXPIRATION_KEY);

        ProposalProgress storage info = _proposalInfo[proposalID];
        uint256 lastTime = info.lastOperationTimestamp;
        if (data.length != 0) {
            expiration = abi.decode(data, (uint256));
        } else {
            return uint256(int256(-1));
        }
        return lastTime + expiration;
    }

    function _createBadge(
        bytes32 badgeKey,
        string memory name,
        uint256 total,
        address target
    ) internal returns (address addr) {
        bytes memory initData = abi.encode(name, target, total);
        return IFactoryManager(_factoryAddress).clone(badgeKey, initData);
    }
}
