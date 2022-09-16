//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseDAO.sol";
import "hardhat/console.sol";

contract MasterDAO is BaseDAO {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    /// structs ////////////////////////////////////////////////////////////////////////

    /// @notice MasterDAO initial data, when create dao,
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
    struct MasterDAOInitData {
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
        FlowInfo[] flows;
    }

    /// @dev dao inforamtion
    MasterDAOInitData private _daoInitData;

    address private _config;

    /// @dev keccak256("FactoryManagerKey");
    bytes32 public constant factoryManagerKey =
        0x618e90bb05c847d0be7158fb3420e6f74c0a99195db496d41aec554825d43862;

    /// @dev NORMAL CATEGORY means the highest priority
    bytes32 public constant DEFAULT_FLOW_ID = 0x0;

    address private _factoryAddress;

    /// variables ////////////////////////////////////////////////////////////////////////
    /// @dev frontend tools to build init data
    function buildInitData(MasterDAOInitData memory initData)
        public
        pure
        returns (bytes memory data)
    {
        return abi.encode(initData);
    }

    function init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        // ownerAddress = admin_;
        // _metadata._init();
        _config = config_;

        /// test
        (bytes32 typeID, bytes memory factoryAddressBytes) = IConfig(_config)
            .getKV(factoryManagerKey);
        console.log("config address:");
        console.log(_config);
        console.log("factory key:");
        console.logBytes32(factoryManagerKey);

        address factoryAddr;
        assembly {
            factoryAddr := mload(add(factoryAddressBytes, 20))
        }
        _factoryAddress = factoryAddr;
        console.log("Factory address:");
        console.log(_factoryAddress);
        console.log("###");
        // init data
        MasterDAOInitData memory initData = abi.decode(
            data,
            (MasterDAOInitData)
        );
        console.logBytes32(DEFAULT_FLOW_ID);
        console.logBytes32(initData.flows[0].flowID);

        /// test end;

        // init committee(Proposer | The Public)

        // name = initData.name;
        // describe = initData.describe;
        // govToken = initData.govTokenAddr;
        // _metadata._setBytesSlice(initData.mds);
        // govTokenAmountRequirement = initData.govTokenAmountRequirement;
        // stakingAddr = initData.stakingAddr;

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

    /// proposals

    /// @dev how many propsoals in the DAO
    ///      also used to generated proposalID;
    uint256 private totalProposal;

    /// @dev proposal storage
    /// proposalID=>Store
    mapping(bytes32 => Proposal) private _proposals;

    function generateProposalID() internal returns (bytes32 proposalID) {
        totalProposal++;
        proposalID = keccak256(abi.encode(_msgSender(), totalProposal));
    }

    /// @notice makeing a new proposal
    /// @dev once making a new proposal
    /// @param proposal content
    /// @param data related content
    /// @return proposalID
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) public override returns (bytes32 proposalID) {
        /* EnsureGovEnough */

        bytes32[] memory agents = proposal.agents;
        if (agents.length == 0) {
            // error
        }

        proposalID = generateProposalID();
        Proposal storage p = _proposals[proposalID];

        p.status = ProposalStatus.PENDING;
        p.proposalID = proposalID;
        p.topicID = proposal.topicID;
        for (uint256 i = 0; i < proposal.headers.length; i++) {
            ItemValue memory itemValue;
            itemValue.typeID = proposal.headers[i].typeID;
            itemValue.data = proposal.headers[i].data;
            p.headers[proposal.headers[i].key] = itemValue;
        }

        // p.contents._init();
        // p.contents._setKVDatas(proposal.contents);

        // 0x 全0 DAO 内部Offchain
        // 0x 全FFF 任意执行，
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            DEFAULT_FLOW_ID
        ];

        bytes32 firstStep = steps[_SENTINEL_ID].nextStep;
        if (firstStep == bytes32(0x0)) {
            revert SystemError();
        }

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
        ProposalProgress storage info = _proposalInfo[proposalID];
        info.proposalID = proposalID;
        info.flowID = DEFAULT_FLOW_ID;

        // decicde next step and which commit is handle the process
        info.nextCommittee.step = firstStep;
        info.nextCommittee.committee = steps[firstStep].committee;

        _decideProposal(proposalID, info.nextCommittee.committee, true);
    }

    function _decideProposal(
        bytes32 proposalID,
        address committee,
        bool agree
    ) internal {
        ProposalProgress storage info = _proposalInfo[proposalID];
        require(info.proposalID == proposalID, "proposal err");
        require(_isNextCommittee(proposalID, committee), "committee err");

        _appendFinishStep(info);
        _setNextStep(info, !agree);

        if (info.nextCommittee.committee == address(0x0)) {
            _execFinish(info, agree);
        }
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

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(byteAddress, 20))
        }
    }

    //////////////////// internal
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
            steps[committeeInfo.step].sensitive = committeeInfo.sensitive;

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

    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external override {}

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
