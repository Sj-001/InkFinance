//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDeploy.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IAgent.sol";
import "../interfaces/IProposalHandler.sol";

import "../bases/BaseVerify.sol";

import "../utils/BytesUtils.sol";
import "../libraries/defined/DutyID.sol";
import "../libraries/defined/TypeID.sol";

import "hardhat/console.sol";

contract ProposalHandler is IProposalHandler, IDeploy, BaseVerify {


    /// @notice store the connection between different committee in a flow
    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
    }

    using Address for address;
    using BytesUtils for bytes;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    string internal constant EXPIRATION_KEY = "Expiration";
    string public constant MIN_EFFECTIVE_VOTES = "MinEffectiveVotes";
    string public constant MIN_EFFECTIVE_VOTE_WALLETS =
        "MinEffectiveVoteWallets";
    string public constant VOTE_FLOW = "VoteFlow";

    /// @dev how many propsoals in the DAO
    /// also used to generated proposalID;
    uint256 private totalProposal;

    /// @dev proposal storage
    /// proposalID=>Store
    mapping(bytes32 => Proposal) internal _proposals;
    /// @dev stored proposal
    /// proposalID=>ProposalProgress
    mapping(bytes32 => ProposalProgress) internal _proposalInfo;

    bytes32 internal constant _SENTINEL_ID =
        0x0000000000000000000000000000000000000000000000000000000000000001;
    /// @dev maintain three basic steps(The Board, The Public+The Board, The Public)
    bytes32[] private _defaultFlows;

    address private _dao;

    /// @notice all the same topic proposal stored here
    /// @dev topicID=>TopicProposal
    mapping(bytes32 => TopicProposal) private _topics;

    /// @notice limit the vote flow steps at most 10 steps
    uint256 public constant MAX_STEP_NUM = 10;

    uint256 private _defaultFlowIDIndex;

        // process category flow ID => (stepID => step info)
    mapping(bytes32 => mapping(bytes32 => StepLinkInfo)) internal _flowSteps;

    modifier onlyDAO() {
        if (_msgSender() != _dao) {
            revert OnlyDAOCouldOperate(_dao, _msgSender());
        }
        _;
    }

    /// @inheritdoc IDeploy
    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // super.init(config_);

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

        _defaultFlowIDIndex = abi.decode(data_, (uint256));
        
        _dao = dao_;

        return callbackEvent;
    }

    function setFlowStep(FlowInfo memory flow) external override onlyDAO {

        _setFlowStep(flow);
    }

    function setupProposalFlow(bytes32 proposalID, bytes32[] memory agents)
        external onlyDAO
    {
        _setupProposalFlow(proposalID, agents);
    }

    function _setupProposalFlow(bytes32 proposalID, bytes32[] memory agents)
        internal
    {

        console.log("_setupProposalFlow: ");
        bytes32 flowID = _getProposalFlow(proposalID);


        console.logBytes32(flowID);

        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[flowID];

        bytes32 firstStep = steps[_SENTINEL_ID].nextStep;

        console.log("first step:");
        console.logBytes32(firstStep);

        require (firstStep != bytes32(0x0), "flow step error");

        ProposalProgress storage info = _proposalInfo[proposalID];
        info.proposalID = proposalID;
        info.flowID = flowID;
        // decicde next step and which commit is handle the process
        info.nextCommittee.step = firstStep;
        info.nextCommittee.committee = steps[firstStep].committee;
        info.lastOperationTimestamp = block.timestamp;
        info.agents = agents;
    }



    function _getProposalFlow(bytes32 proposalID)
        internal
        view
        returns (bytes32 flowID)
    {


        bytes32 proposalFlowID = 0x0000000000000000000000000000000000000000000000000000000000000004;

        (bytes32 typeID, bytes memory voteFlow) = getProposalMetadata(
            proposalID,
            VOTE_FLOW
        );

        if (typeID == TypeID.BYTES32) {
            // console.log("Proposal Handler");

            flowID = abi.decode(voteFlow, (bytes32));
            // console.logBytes32(value);
            if (flowID > 0) {
                return flowID;
            }
        }

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
                    flowID = proposalFlowID;
                    break;
                }
            }


            require (support, "Flow is not support");
            // if (support) {
            //     flowID = proposalFlowID;
            // } else {
            //     require(false, "Flow is not support");
            //     // revert FlowIsNotSupport(_defaultFlowIDIndex, proposalFlowID);
            // }
        }
    }


    /// @inheritdoc IProposalHandler
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        address proposer,
        bytes calldata data
    ) public override onlyDAO returns (bytes32 proposalID) {
        /* EnsureGovEnough */
        proposalID = _newProposal(proposal, commit, proposer, data);

        _setupProposalFlow(proposalID, proposal.agents);
    }

    /// @inheritdoc IProposalHandler
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 proposalID)
    {
        return _getTopicKeyProposal(topicID, key);
    }

    function _getTopicKeyProposal(bytes32 topicID, string memory key)
        internal
        view
        returns (bytes32 proposalID)
    {
        TopicProposal storage topic = _topics[topicID];
        return
            topic.key2Proposal[LEnumerableMetadata._getKeyID(key)].proposalID;
    }

    /// @inheritdoc IProposalHandler
    function getTopicMetadata(bytes32 topicID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    /// @inheritdoc IProposalHandler
    function getTopicInfo(bytes32 topicID)
        external
        view
        override
        returns (Topic memory topic)
    {}

    /// @inheritdoc IProposalHandler
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

    /// @inheritdoc IProposalHandler
    function getProposalMetadata(bytes32 proposalID, string memory key)
        public
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        Proposal storage proposal = _proposals[proposalID];
        return (proposal.metadata[key].typeID, proposal.metadata[key].data);
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
        bytes32 proposalID = _getTopicKeyProposal(topicID, key);

        // if (!_isProposalExist(proposalID)) {
        //     return (typeID, data);
        // }

        return _proposals[proposalID].kvData._getByKey(key);
    }

    /// @inheritdoc IProposalHandler
    function getProposalKvData(bytes32 proposalID, string memory key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        return _proposals[proposalID].kvData._getByKey(key);
    }

    /// @inheritdoc IProposalHandler
    function getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) external view override returns (string[] memory keys) {
        return _getProposalKvDataKeys(proposalID, startKey, pageSize);
    }

    function _getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) internal view returns (string[] memory keys) {
        Proposal storage proposal = _proposals[proposalID];
        return proposal.kvData._getAllKeys(startKey, pageSize);
    }

    /// @inheritdoc IProposalHandler
    function getProposalTopic(bytes32 proposalID)
        external
        view
        override
        returns (bytes32 topicID)
    {
        return _proposals[proposalID].topicID;
    }

    /// @inheritdoc IProposalHandler
    function flushTopicIndex(bytes32 topicID, uint256 operateNum)
        external
        override
        onlyDAO
    {}

    function getProposalFlow(bytes32 proposalID)
        external
        view
        override
        returns (bytes32 flowID)
    {
        flowID = _getProposalFlow(proposalID);
    }

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
        // DAO default setting
        minAgreeRatio = 60;
        minEffectiveVotes = 0;
        minEffectiveWallets = 0;

        // reading from the proposal metadata, which has the higer priority.

        (bytes32 typeID, bytes memory minVoteData) = getProposalMetadata(
            proposalID,
            MIN_EFFECTIVE_VOTES
        );
        if (typeID == TypeID.UINT256) {
            uint256 value = abi.decode(minVoteData, (uint256));
            if (value > 0) {
                minEffectiveVotes = value;
            }
        }

        bytes memory minWalletData;
        (typeID, minWalletData) = getProposalMetadata(
            proposalID,
            MIN_EFFECTIVE_VOTE_WALLETS
        );

        if (typeID == TypeID.UINT256) {
            uint256 value = abi.decode(minWalletData, (uint256));
            if (value > 0) {
                minEffectiveWallets = value;
            }
        }
    }

    function _getTopicInfo(bytes32 topicID)
        internal
        view
        returns (Topic memory topic)
    {
        TopicProposal storage r = _topics[topicID];

        topic.topicID = r.topicID;
        topic.proposalIDs = r.proposalIDs;

        return topic;
    }

    function execProposalMessage(bytes32 proposalID, bytes memory messages)
        external
        override
        onlyDAO
    {
        Proposal storage p = _proposals[proposalID];

        require(p.proposalID == proposalID, "not exist");
        require(p.status == ProposalStatus.AGREE, "not succ proposal");

        Topic memory topic = _getTopicInfo(p.topicID);

        bytes32 nowProposalID = topic.proposalIDs[topic.proposalIDs.length - 1];

        console.log("execute succeed");

        emit ExecuteOffchainMessage(
            topic.topicID,
            _msgSender(),
            proposalID,
            _dao,
            nowProposalID,
            messages,
            block.timestamp
        );
    }

    // function _setTopicID(Proposal storage p) private {
    //     (, bytes memory data) = p.metadata._get(MetadataKeyID.TOPIC_ID);
    //     if (data.length == 0) {
    //         return;
    //     }

    //     bytes32 topicID = abi.decode(data, (bytes32));
    //     require(_isTopicExist(topicID), "not have topic");
    //     require(
    //         _topics[topicID].dao == _msgSender(),
    //         "can't fix other dao topic"
    //     );

    //     p.topicID = topicID;
    // }

    function _isTopicExist(bytes32 topicID) private view returns (bool) {
        if (topicID == bytes32(0x0)) {
            return false;
        }

        if (_topics[topicID].topicID == bytes32(0x0)) {
            return false;
        }

        return true;
    }

    // if agree, apply the proposal kvdata to topic.
    function syncProposalKvDataToTopic(
        bytes32 proposalID,
        bool agree,
        bytes memory
    ) internal {
        Proposal storage p = _proposals[proposalID];
        // make sure caller is the committee
        // require(p.dao == _msgSender(), "dao error");
        // require(p.status == ProposalStatus.PENDING, "proposal status err");

        if (!agree) {
            // p.status = ProposalStatus.DENY;
            emit ProposalTopicSynced(proposalID, agree, bytes32(0x0));
            return;
        }

        // p.status = ProposalStatus.AGREE;

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

        t.proposalIDs.push();
        uint256 newIdx = t.proposalIDs.length - 1;
        t.proposalIDs[newIdx] = proposalID;

        string[] memory keys = _getProposalKvDataKeys(
            proposalID,
            "",
            p.kvData.size
        );
        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 keyID = LEnumerableMetadata._getKeyID(keys[i]);
            TopicKey2Proposal storage keymap = t.key2Proposal[keyID];
            keymap.proposalID = proposalID;
            keymap.proposalIdx = newIdx;
        }

        emit ProposalTopicSynced(proposalID, agree, topicID);
    }

    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external override onlyDAO {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IProposalHandler).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    function _newProposal(
        NewProposalInfo memory proposal,
        bool commit,
        address proposer,
        bytes memory data
    ) internal returns (bytes32 proposalID) {
        bytes32[] memory agents = proposal.agents;
        if (agents.length == 0) {
            // error
        }

        proposalID = _generateProposalID();
        Proposal storage p = _proposals[proposalID];

        p.agents = proposal.agents;
        p.status = ProposalStatus.PENDING;
        p.proposalID = proposalID;

        if (proposal.topicID == 0x0) {
            proposal.topicID = keccak256(
                abi.encodePacked(address(this), proposalID)
            );
        }

        // console.logBytes32("proposalID::::");
        // console.logBytes32(p.proposalID);

        p.topicID = proposal.topicID;
        for (uint256 i = 0; i < proposal.metadata.length; i++) {
            ItemValue memory itemValue;
            itemValue.typeID = proposal.metadata[i].typeID;
            itemValue.data = proposal.metadata[i].data;
            p.metadata[proposal.metadata[i].key] = itemValue;

        }

        p.kvData._init();
        p.kvData._setBytesSlice(proposal.kvData);
    }

    function _generateProposalID() internal returns (bytes32 proposalID) {
        totalProposal++;
        proposalID = keccak256(abi.encode(_msgSender(), totalProposal));
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
        // console.log("next committee:", nextCommittee);
        if (nextCommittee == address(0x0)) {
            return false;
        }

        return nextCommittee == committee;
    }


    function getNextVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        override
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


    function getVotedCommittee(bytes32 proposalID)
        external
        view
        override
        returns (address[] memory committee)
    {
        ProposalProgress storage info = _proposalInfo[proposalID];

        uint256 committeeSize = info.committees.length;
        committee = new address[](committeeSize);
        for (uint256 i = 0; i < committeeSize; i++) {
            committee[i] = info.committees[i].committee;
        }
    }


    function _appendFinishStep(ProposalProgress storage info) internal {
        CommitteeInfo storage committeeInfo = info.committees.push();
        committeeInfo.committee = info.nextCommittee.committee;
        committeeInfo.step = info.nextCommittee.step;
        info.lastOperationTimestamp = block.timestamp;
    }

    /// @inheritdoc IProposalHandler
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external override onlyDAO {

        _decideProposal(proposalID, agree, data);
    }


    function _decideProposal(
        bytes32 proposalID,
        // address committee,
        bool agree,
        bytes memory data
    ) internal {

        ProposalProgress storage info = _proposalInfo[proposalID];
        require(info.proposalID == proposalID, "proposal err");
        // why need to verify the next committee...
        // require(_isNextCommittee (proposalID, committee), "committee err");

        _appendFinishStep(info);
        _setNextStep(info, !agree);


        if (info.nextCommittee.committee == address(0x0)) {

            Proposal storage proposal = _proposals[proposalID];
            require(proposal.status == ProposalStatus.PENDING, "The proposal is already decided");

            if (agree == false) {
                proposal.status = ProposalStatus.DENY;
            } else {
                proposal.status = ProposalStatus.AGREE;
                syncProposalKvDataToTopic(proposalID, agree, "");
            }

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

    function getVoteExpirationTime(bytes32 proposalID)
        external
        view
        override
        returns (uint256 expiration)
    {
        (, bytes memory data) = getProposalMetadata(proposalID, EXPIRATION_KEY);
        ProposalProgress storage info = _proposalInfo[proposalID];
        uint256 lastTime = info.lastOperationTimestamp;
        if (data.length != 0) {
            expiration = abi.decode(data, (uint256));
        } else {
            return uint256(int256(-1));
        }
        return lastTime + expiration;
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

                address deployedAddress = IDAO(_dao).deployCommittees(
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
        }
    }

    
    function _execFinish(ProposalProgress storage info, bool agree) internal {
        
        require(info.nextCommittee.committee == address(0x0), "can't finish");

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

                    IDAO(_dao).delegateExecuteAgent(agents[i], info.proposalID);
                
                }
            }
        }

        emit ProposalDecide(
            address(this),
            info.proposalID,
            agree,
            _proposals[info.proposalID].topicID,
            block.timestamp
        );
    }

    function getSupportedFlow() external view override returns (bytes32[] memory flows) {
        flows = new bytes32[](_defaultFlows.length - _defaultFlowIDIndex);
        uint256 startIndex = 0;
        for (uint256 i = _defaultFlowIDIndex; i < _defaultFlows.length; i++) {
            flows[startIndex] = _defaultFlows[i];
            startIndex++;
        }
    }


    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
