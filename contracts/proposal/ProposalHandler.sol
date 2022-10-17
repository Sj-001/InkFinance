//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDeploy.sol";
import "../interfaces/IProposalHandler.sol";

import "../bases/BaseVerify.sol";

import "../utils/BytesUtils.sol";
import "../libraries/defined/DutyID.sol";
import "../libraries/defined/TypeID.sol";

import "hardhat/console.sol";

contract ProposalHandler is IProposalHandler, IDeploy, BaseVerify {

    using Address for address;
    using BytesUtils for bytes;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

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

    address private _dao;

    /// @notice all the same topic proposal stored here
    /// @dev topicID=>TopicProposal
    mapping(bytes32 => TopicProposal) private _topics;

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

        _dao = dao_;
        return callbackEvent;
    }

    /// @inheritdoc IProposalHandler
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) public override onlyDAO returns (bytes32 proposalID) {
        /* EnsureGovEnough */
        proposalID = _newProposal(proposal, commit, data);
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

        // console.log("get topic key value");
        // console.logBytes32(topicID);
        // console.logBytes32(proposalID);

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
        (bytes32 typeID, bytes memory voteFlow) = getProposalMetadata(
            proposalID,
            VOTE_FLOW
        );

        if (typeID == TypeID.BYTES32) {
            console.log("Proposal Handler");

            bytes32 value = abi.decode(voteFlow, (bytes32));
            console.logBytes32(value);
            if (value > 0) {
                flowID = value;
            }
        }
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

    /// @inheritdoc IProposalHandler
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external override onlyDAO {
        Proposal storage proposal = _proposals[proposalID];
        if (agree == false) {
            proposal.status = ProposalStatus.DENY;
        } else {
            proposal.status = ProposalStatus.AGREE;
            syncProposalKvDataToTopic(proposalID, agree, "");
        }
    }




    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
