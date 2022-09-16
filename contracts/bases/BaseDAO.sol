//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IFactoryManager.sol";

import "./BaseVerify.sol";
import "hardhat/console.sol";

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using EnumerableSet for EnumerableSet.AddressSet;

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

    // functions ////////////////////////////////////////////////////////////////////////
    function generateProposalID() internal returns (bytes32 proposalID) {
        totalProposal++;
        proposalID = keccak256(abi.encode(_msgSender(), totalProposal));
    }

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(byteAddress, 20))
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
    function getTopicKeyProposal(bytes32 topicID, bytes32 key)
        external
        view
        override
        returns (bytes32 proposalID)
    {}

    function getTopicMetadata(bytes32 topicID, bytes32 key)
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
    {}

    function getProposalMetadata(bytes32 proposalID, bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getProposalKvData(bytes32 proposalID, bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getProposalKvDataKeys(
        bytes32 proposalID,
        bytes32 startKey,
        uint256 pageSize
    ) external view override returns (bytes32[] memory keys) {}

    //////////////////// flush index
    // dao查看该topicID上次刷新到的位置(lastIndexedProposalID, lastIndexedKey), 来继续进行, 所以权限问题.
    function flushTopicIndex(bytes32 topicID, uint256 operateNum)
        external
        override
    {}

    // if agree, apply the proposal kvdata to topic.
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes memory
    ) public override {
        Proposal storage p = _proposals[proposalID];
        // require(p.dao == _msgSender(), "dao error");
        require(p.status == ProposalStatus.PENDING, "proposal status err");

        if (!agree) {
            p.status = ProposalStatus.DENY;
            // emit EProposalDecide(_msgSender(), proposalID, agree, bytes32(0x0));
            return;
        }

        p.status = ProposalStatus.AGREE;

        bytes32 topicID;
        if (p.topicID == bytes32(0x0)) {
            topicID = keccak256(abi.encode(proposalID));
        } else {
            topicID = p.topicID;
        }

        // StoreTopic storage t = _topics[topicID];
        // if (p.topicID == bytes32(0x0)) {
        //     // new
        //     p.topicID = topicID;

        //     t.topicID = topicID;
        //     t.dao = _msgSender();
        //     // emit ETopicCreate(_msgSender(), topicID, proposalID);
        // } else {
        //     // emit ETopicFix(_msgSender(), topicID, proposalID);
        // }

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

        // emit EProposalDecide(_msgSender(), proposalID, agree, topicID);
    }

    function getFlowSteps(bytes32 flowID)
        external
        view
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

    function _execFinish(ProposalProgress storage info, bool agree) internal {
        require(info.nextCommittee.committee == address(0x0), "can't finish");
        decideProposal(info.proposalID, agree, "");
        // emit EDecideProposal(info.proposalID, agree);
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

            // Deploy committee
            // require(
            //     ICommittee(committeeAddress).supportsInterface(
            //         type(ICommittee).interfaceId
            //     ),
            //     "committee addr not support ICommittee"
            // );

            bytes memory initData = abi.encode("1", "2");
            // keccak256(toUtf8Bytes("CommitteeTypeID"))
            address committeeAddress2 = IFactoryManager(_factoryAddress).deploy(
                0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f,
                committeeInfo.addressConfigKey,
                initData
            );

            console.log("deployed address:", committeeAddress2);

            steps[committeeInfo.step].committee = committeeAddress2;

            // link next committee
            if (j < flow.committees.length - 1) {
                steps[committeeInfo.step].nextStep = flow
                    .committees[j + 1]
                    .step;
            } else {
                steps[committeeInfo.step].nextStep = bytes32(0x0);
            }
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
