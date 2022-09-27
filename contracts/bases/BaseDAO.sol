//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IFactoryManager.sol";
import "../interfaces/IAgent.sol";

import "./BaseVerify.sol";
import "../utils/BytesUtils.sol";

import "hardhat/console.sol";

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;
    using BytesUtils for bytes;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// structs ////////////////////////////////////////////////////////////////////////
    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
    }

    /// @notice BaseDAO initial data, when create dao,
    /// these data is necessary for creating the DAO instance.
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
    struct BaseDAOInitData {
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        string badgeName;
        uint256 badgeTotal;
        string daoLogo;
        uint256 minPledgeRequired;
        uint256 minEffectiveVotes;
        uint256 minEffectiveVoteWallets;
        bytes32 factoryManagerKey;
        FlowInfo[] flows;
    }

    // variables ////////////////////////////////////////////////////////////////////////
    // constant
    uint256 public constant MAX_STEP_NUM = 10;

    bytes32 internal constant _SENTINEL_ID =
        0x0000000000000000000000000000000000000000000000000000000000000001;

    /// @dev DEFAULT_FLOW_ID means the highest priority
    bytes32 public constant DEFAULT_FLOW_ID = 0x0;

    // @dev the one who created the DAO
    address private _ownerAddress;
    /// @notice DAO name;
    string private _name;
    string private _describe;
    IERC20 private _govToken;
    uint256 private _govTokenAmountRequirement;
    address private _stakingAddr;
    address private _configManager;
    address private _factoryAddress;

    uint256 private _minPledgeRequired;
    uint256 private _minEffectiveVotes;
    uint256 private _minEffectiveVoteWallets;
    ///@dev BoardOnly=1, PublicAndBoard=10, Public Only=100
    uint256 private _voteMode;

    /// @dev how many propsoals in the DAO
    ///      also used to generated proposalID;
    uint256 private totalProposal;

    /// @dev key is dutyID
    /// find duty members according to dutyID,
    mapping(bytes32 => EnumerableSet.AddressSet) private _dutyMembers;

    /// @notice how many dutyIDs the EOA address have in the DAO
    /// @dev once the _dutyCounts become 0, it should be removed from the DAO
    mapping(address => uint256) private _dutyCounts;

    // process category flow ID => (stepID => step info)
    mapping(bytes32 => mapping(bytes32 => StepLinkInfo)) internal _flowSteps;

    /// @dev stored proposal
    /// proposalID=>ProposalProgress
    mapping(bytes32 => ProposalProgress) internal _proposalInfo;

    /// @dev proposal storage
    /// proposalID=>Store
    mapping(bytes32 => Proposal) internal _proposals;

    /// for test
    EnumerableSet.Bytes32Set internal _proposalsArray;

    /// @notice all the same topic proposal stored here
    /// @dev topicID=>TopicProposal
    mapping(bytes32 => TopicProposal) private _topics;

    // test functins
    function getProposalIDByIndex(uint256 index)
        external
        view
        returns (bytes32 _proposalID)
    {
        _proposalID = _proposalsArray.at(index);
    }

    function setFlowStep(FlowInfo memory flow) public {
        // require(msg.sender == address(this), "not myself");
        _setFlowStep(flow);
    }

    function _newProposal(
        NewProposalInfo memory proposal,
        bool commit,
        bytes memory data
    ) internal returns (bytes32 proposalID) {
        bytes32[] memory agents = proposal.agents;
        if (agents.length == 0) {
            // error
        }

        proposalID = generateProposalID();
        Proposal storage p = _proposals[proposalID];

        p.agents = proposal.agents;

        console.log("proposal is:");
        console.logBytes32(proposalID);
        console.log("agents is:");
        console.logBytes32(p.agents[0]);

        p.status = ProposalStatus.PENDING;
        p.proposalID = proposalID;
        p.topicID = proposal.topicID;
        // p.headers._init();
        console.log("show init data");
        console.log(proposal.metadata[0].key);

        // p.headers._setBytesSlice(proposal.headers);

        for (uint256 i = 0; i < proposal.metadata.length; i++) {
            ItemValue memory itemValue;
            itemValue.typeID = proposal.metadata[i].typeID;
            itemValue.data = proposal.metadata[i].data;
            p.metadata[proposal.metadata[i].key] = itemValue;
        }

        p.kvData._init();
        console.log("kv data bytes");
        console.logBytes(proposal.kvData[0]);
        p.kvData._setBytesSlice(proposal.kvData);

        bytes32 flowID = _getAgentFlowID(agents[0]);

        // 0x 全0 DAO 内部Offchain
        // 0x 全FFF 任意执行，
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[flowID];

        bytes32 firstStep = steps[_SENTINEL_ID].nextStep;
        if (firstStep == bytes32(0x0)) {
            revert SystemError();
        }

        ProposalProgress storage info = _proposalInfo[proposalID];
        info.proposalID = proposalID;
        // decicde next step and which commit is handle the process
        info.nextCommittee.step = firstStep;
        info.nextCommittee.committee = steps[firstStep].committee;
    }

    /// @inheritdoc IProposalHandler
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) public override returns (bytes32 proposalID) {
        /* EnsureGovEnough */

        proposalID = _newProposal(proposal, commit, data);

        // bytes32[] memory proposer_duties = ICommittee(
        //     steps[firstStep].committee
        // ).getCommitteeDuties();

        // if (!_hasDuty(_msgSender(), proposer_duties[0])) {
        //     revert NotAllowedToOperate();
        // }

        // require(_msgSender() == steps[firstStep].committee, "no right");

        // IProposalRegistry proposalRegistry = _getProposalRegistry();
        // proposalID = proposalRegistry.newProposal(proposal, data);

        // initial process of the progress
        // ProposalProgress storage info = _proposalInfo[proposalID];
        // info.proposalID = proposalID;

        // info.flowID = _getAgentFlowID(agents[0]);
        // console.log("agent is::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
        // console.logBytes32(agents[0]);
        // console.log("agent flow id is::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
        // console.logBytes32(info.flowID);

        // // decicde next step and which commit is handle the process
        // info.nextCommittee.step = firstStep;
        // info.nextCommittee.committee = steps[firstStep].committee;

        // _decideProposal(proposalID, info.nextCommittee.committee, true);
    }

    // @inheritdoc IDAO
    // function callFromDAO(
    //     bytes memory functionSignature
    // ) external override returns (bool success, bytes memory returnedBytes) {
    //     /// very import to verify the caller
    //     (success, returnedBytes) = address(contractAddress).call(
    //         functionSignature
    //     );
    // }

    // functions ////////////////////////////////////////////////////////////////////////
    function generateProposalID() internal returns (bytes32 proposalID) {
        totalProposal++;
        proposalID = keccak256(abi.encode(_msgSender(), totalProposal));
        console.log(
            "generated ################################################"
        );
        /// for test
        _proposalsArray.add(proposalID);
    }

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(byteAddress, 32))
        }
    }

    function init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        // init data
        BaseDAOInitData memory initData = abi.decode(data, (BaseDAOInitData));

        _ownerAddress = admin_;
        _name = initData.name;
        _describe = initData.describe;
        _govToken = initData.govTokenAddr;
        _govTokenAmountRequirement = initData.govTokenAmountRequirement;
        _stakingAddr = initData.stakingAddr;

        (bytes32 typeID, bytes memory factoryAddressBytes) = configManager
            .getKV(initData.factoryManagerKey);
        address factoryAddr;
        assembly {
            factoryAddr := mload(add(factoryAddressBytes, 20))
        }

        _factoryAddress = factoryAddr;

        // _metadata._init();
        // _metadata._setBytesSlice(initData.mds);
        // require(initData.flows.length != 0, "no flow set");
        for (uint256 i = 0; i < initData.flows.length; i++) {
            _setFlowStep(initData.flows[i]);
        }

        // if(bytes(initData.badgeName).length != 0){
        //   _badge = InkBadgeERC20Factory(IAddressRegistry(addrRegistry).getAddress(AddressID.InkBadgeERC20Factory)).CreateBadge(initData.badgeName, initData.badgeName, initData.badgeTotal, admin);
        //   emit EBadge(_badge, initData.name, initData.badgeTotal);
        // }
        // CallbackData memory callbackData;
        // callbackData.addr = address(this);
        // callbackData.admin = admin_;
        // callbackData.govTokenAddr = address(govToken);
        // callbackData.name = name;
        // return abi.encode(callbackData);

        return bytes("");
    }

    /// @inheritdoc IDutyControl
    function addDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function remmoveDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function addUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function removeUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function hasDuty(address account, bytes32 dutyID)
        external
        override
        returns (bool exist)
    {
        exist = _hasDuty(account, dutyID);
    }

    function _hasDuty(address account, bytes32 dutyID)
        internal
        returns (bool exist)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwners(bytes32 dutyID)
        external
        override
        returns (uint256 owners)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        override
        returns (address addr)
    {}

    // which proposal decide the latest key item;
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 proposalID)
    {}

    function getTopicMetadata(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getTopicInfo(bytes32 topicID)
        external
        view
        override
        returns (Topic memory topic)
    {}

    //////////////////// proposal

    function getProposalSummary(bytes32 proposalID)
        external
        view
        override
        returns (ProposalSummary memory proposal)
    {
        Proposal storage p = _proposals[proposalID];
        proposal.status = p.status;
        proposal.proposalID = p.proposalID;
        proposal.topicID = p.topicID;
        // proposal.dao = p.dao;
        return proposal;
    }

    function getProposalMetadata(bytes32 proposalID, string memory key)
        public
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        Proposal storage proposal = _proposals[proposalID];
        return (proposal.metadata[key].typeID, proposal.metadata[key].data);
    }

    function getProposalKvData(bytes32 proposalID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
                
        return _proposals[proposalID].kvData._getByKey(key);
    }

    function getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) external view override returns (string[] memory keys) {
        Proposal storage proposal = _proposals[proposalID];
        return proposal.kvData._getAllKeys(startKey, pageSize);
    }

    //////////////////// flush index
    // dao查看该topicID上次刷新到的位置(lastIndexedProposalID, lastIndexedKey), 来继续进行, 所以权限问题.
    function flushTopicIndex(bytes32 topicID, uint256 operateNum)
        external
        override
    {}

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
        if (
            agentID ==
            0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1
        ) {
            return keccak256("financial-payroll-setup");
        }
        return DEFAULT_FLOW_ID;
    }

    /// @inheritdoc IAgentHandler
    function execTx(TxInfo[] memory txs) external override {}

    // function getProposalVoteLimit(bytes32 proposalID) public view returns(uint256 minVotes, uint256 minWallets, uint256 minAgreeRatio){

    //   // DAO default setting
    //   minVotes = _minEffectiveVotes;
    //   minWallets = _minEffectiveVoteWallets;
    //   minAgreeRatio = _minEffectiveVoteWallets;

    // reading from the proposal metadata, which has the higer priority.

    //   (bytes32 typeID, bytes memory minVoteData) = getProposalMetadata(proposalID, MIN_VOTES);
    //   if(typeID == TypeID.UINT256){
    //     uint256 value = abi.decode(minVoteData, (uint256));
    //     if(value > 0){
    //       minVotes = value;
    //     }
    //   }

    //   bytes memory minWalletData;
    //   (typeID, minWalletData) = proposalRegistry.getProposalMetadata(proposal.proposalID, MIN_WALLETS);
    //   if(typeID == TypeID.UINT256){
    //     uint256 value = abi.decode(minWalletData, (uint256));
    //     if(value > 0){
    //       minWallets = value;
    //     }
    //   }

    //   return (minVotes, minWallets, );
    // }

    // if agree, apply the proposal kvdata to topic.
    function syncProposalKvDataToTopic(
        bytes32 proposalID,
        bool agree,
        bytes memory
    ) internal {
        Proposal storage p = _proposals[proposalID];
        // make sure caller is the committee
        // require(p.dao == _msgSender(), "dao error");
        require(p.status == ProposalStatus.PENDING, "proposal status err");

        if (!agree) {
            p.status = ProposalStatus.DENY;
            emit ProposalTopicSynced(proposalID, agree, bytes32(0x0));
            return;
        }

        p.status = ProposalStatus.AGREE;

        bytes32 topicID;
        if (p.topicID == bytes32(0x0)) {
            topicID = keccak256(abi.encode(proposalID));
        } else {
            topicID = p.topicID;
        }

        TopicProposal storage t = _topics[topicID];
        if (p.topicID == bytes32(0x0)) {
            // new
            p.topicID = topicID;
            t.topicID = topicID;
            emit TopicCreate(topicID, proposalID);
        } else {
            emit TopicFix(topicID, proposalID);
        }

        // t.proposalIDs.push();
        // uint256 newIdx = t.proposalIDs.length - 1;
        // t.proposalIDs[newIdx] = proposalID;

        // string[] memory keys = getProposalKvDataKeys(
        //     proposalID,
        //     "",
        //     p.kvData.size
        // );
        // for (uint256 i = 0; i < keys.length; i++) {
        //     bytes32 keyID = LEnumerableMetadata._getKeyID(keys[i]);
        //     TopicKey2Proposal storage keymap = t.key2Proposal[keyID];
        //     keymap.proposalID = proposalID;
        //     keymap.proposalIdx = newIdx;
        // }

        emit ProposalTopicSynced(proposalID, agree, topicID);
    }

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

    //////////////////// internal

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
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) internal returns (address deployedAddress) {
        bytes memory deployCall = abi.encodeWithSignature(
            "deploy(bytes32,bytes32,bytes)",
            typeID,
            contractKey,
            initData
        );
        console.log("before call:");
        console.logBytes32(typeID);
        console.logBytes32(contractKey);

        (bool _success, bytes memory _returnedBytes) = address(_factoryAddress)
            .call(deployCall);

        console.log("deploy by key:");
        console.log(_success);
        console.logBytes(_returnedBytes);

        if (_success) {
            deployedAddress = turnBytesToAddress(_returnedBytes);
        }
    }

    function deployByKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) external override returns (address deployedAddress) {



        bytes memory deployCall = abi.encodeWithSignature(
            "deploy(bytes32,bytes32,bytes)",
            typeID,
            contractKey,
            initData
        );
        console.log("before call:");
        console.logBytes32(typeID);
        console.logBytes32(contractKey);
        // console.logBytes(contractKey);

        (bool _success, bytes memory _returnedBytes) = address(_factoryAddress)
            .call(deployCall);

        console.log("deploy by key:");
        console.log(_success);
        console.logBytes(_returnedBytes);

        if (_success) {
            deployedAddress = turnBytesToAddress(_returnedBytes);
        }
    }

    function _execFinish(ProposalProgress storage info, bool agree) internal {
        require(info.nextCommittee.committee == address(0x0), "can't finish");

        syncProposalKvDataToTopic(info.proposalID, agree, "");
        // emit EDecideProposal(info.proposalID, agree);
        console.log("exec finished");

        if (agree == true) {
            console.log("info proposal is:");
            console.logBytes32(info.proposalID);

            Proposal storage p = _proposals[info.proposalID];
            console.log("agent length:", p.agents.length);
            console.log("proposal is:");
            console.logBytes32(p.proposalID);

            for (uint256 i = 0; i < p.agents.length; i++) {
                if (
                    p.agents[i] !=
                    0x0000000000000000000000000000000000000000000000000000000000000000
                ) {
                    console.log("");
                    console.log(
                        "START TO GENRATE AGENT ############################################################################################################"
                    );

                    bytes memory initData = abi.encode("");
                    bytes memory deployCall = abi.encodeWithSignature(
                        "deploy(bytes32,bytes32,bytes)",
                        0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845,
                        p.agents[i],
                        initData
                    );
                    (bool success, bytes memory returnedBytes) = address(
                        _factoryAddress
                    ).call(deployCall);

                    console.log(
                        "DEPLOY END ############################################################################################################"
                    );
                    console.log("");

                    if (success) {
                        // execute the Proposal
                        address agentAddress = turnBytesToAddress(
                            returnedBytes
                        );
                        IAgent(agentAddress).initAgent(address(this));
                        IAgent(agentAddress).preExec(info.proposalID);
                        IAgent(agentAddress).exec(info.proposalID);
                    }
                }
            }
        }
    }

    function _setNextStep(ProposalProgress storage info, bool breakFlow)
        internal
    {
        if (!breakFlow) {
            bytes32 flowID = info.flowID;
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

    function setupFlowInfo(FlowInfo memory flow) external override {
        _setFlowStep(flow);
    }


        /// @inheritdoc IDAO
    function setupUCV(bytes32 contractKey, bytes memory initData)
        external
        override
    {
        console.log("setup ucv ---------------- ");

        address deployedUCV = _deployByFactoryKey(
            0x7f16b5baf10ee29b9e7468e87c742159d5575c73984a100d194e812750cad820,
            contractKey,
            initData
        );

        // require deploy succeed
        console.log("ucv:", deployedUCV);
    }

    function _setFlowStep(FlowInfo memory flow) internal {
        // _factoryAddress;
        require(flow.committees.length < MAX_STEP_NUM, "too many steps");
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            flow.flowID
        ];

        // init sentinel.
        steps[_SENTINEL_ID].nextStep = flow.committees[0].step;

        for (uint256 j = 0; j < flow.committees.length; j++) {
            CommitteeCreateInfo memory committeeInfo = flow.committees[j];

            bytes32[] memory duties = abi.decode(
                committeeInfo.dutyIDs,
                (bytes32[])
            );
            // bytes32[] memory duties;

            // console.logBytes(committeeInfo.dutyIDs);
            // console.log("duty length:::", duties.length);
            // console.logBytes32(committeeInfo.addressConfigKey);
            // (bytes32 typeID, bytes memory committeeAddressBytes) = IConfig(_config).getKV(committeeInfo.addressConfigKey);

            // // valid typeID
            // address committeeAddress = turnBytesToAddress(committeeAddressBytes);
            // console.log("committee address:", committeeAddress);

            require(
                committeeInfo.step != bytes32(0x0) &&
                    committeeInfo.step != _SENTINEL_ID,
                "step empty"
            );
            console.log("");
            console.log(
                "START TO GENRATE ############################################################################################################"
            );
            // Deploy committee
            // require(
            //     ICommittee(committeeAddress).supportsInterface(
            //         type(ICommittee).interfaceId
            //     ),
            //     "committee addr not support ICommittee"
            // );

            bytes memory initData = abi.encode(duties);
            address committeeAddress = _deployByFactoryKey(
                0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f,
                committeeInfo.addressConfigKey,
                initData
            );

            console.log("deploy committee address by key:", committeeAddress);
            console.logBytes32(committeeInfo.addressConfigKey);
            console.log("deployed committee address:", committeeAddress);

            // bytes memory deployCall = abi.encodeWithSignature(
            //     "deploy(bytes32,bytes32,bytes)",
            //     0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f,
            //     committeeInfo.addressConfigKey,
            //     initData
            // );
            // address committeeAddress2 = IFactoryManager(_factoryAddress).deploy(
            //     0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f,
            //     committeeInfo.addressConfigKey,
            //     initData
            // );
            // (bool success, bytes memory returnedBytes) = address(
            //     _factoryAddress
            // ).call(deployCall);
            // console.log("returned bytes");
            // console.logBytes(returnedBytes);
            // console.log(success);
            // console.log("turned address", turnBytesToAddress(returnedBytes));
            console.log("set step's committee is:", committeeAddress);
            console.log("step is:");
            console.logBytes32(committeeInfo.step);

            steps[committeeInfo.step].committee = committeeAddress;

            // link next committee
            if (j < flow.committees.length - 1) {
                steps[committeeInfo.step].nextStep = flow
                    .committees[j + 1]
                    .step;
            } else {
                steps[committeeInfo.step].nextStep = bytes32(0x0);
            }

            console.log(
                "DEPLOY END ############################################################################################################"
            );
            console.log("");
        }
    }

    function _decideProposal(
        bytes32 proposalID,
        address committee,
        bool agree
    ) internal {
        ProposalProgress storage info = _proposalInfo[proposalID];

        require(info.proposalID == proposalID, "proposal err");

        // why need to verify the next committee...
        // require(_isNextCommittee (proposalID, committee), "committee err");

        _appendFinishStep(info);
        _setNextStep(info, !agree);

        if (info.nextCommittee.committee == address(0x0)) {
            _execFinish(info, agree);
        }
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

    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external override {}

    modifier EnsureGovEnough() {
        require(
            _govToken.balanceOf(_ownerAddress) > _govTokenAmountRequirement,
            "admin's gov not enough"
        );
        _;
    }
}
