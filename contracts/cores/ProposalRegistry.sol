//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../bases/BaseVerify.sol";
import "../interfaces/IConfig.sol";
import "../interfaces/IProposalRegistry.sol";

import "../libraries/defined/MetadataKeyID.sol";
import "../libraries/defined/AddressTag.sol";

import "../libraries/LEnumerableMetadata.sol";

/// @title ProposalRegistry
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice ProposalRegistry is used to to record all the proposal created.
contract ProposalRegistry is Context, BaseVerify, IProposalRegistry {
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;

    struct StoreProposal {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        // if one dao was upgraded, the dao addr is the origin address.
        address dao;
        LEnumerableMetadata.MetadataSet metadata;
        LEnumerableMetadata.MetadataSet kvData;
    }

    struct TopicKey2Proposal {
        bytes32 proposalID;
        uint256 proposalIdx;
    }

    struct StoreTopic {
        bytes32 topicID;
        // current dao.
        address dao;
        bytes32[] proposalIDs;
        // keyid => latest proposal
        mapping(bytes32 => TopicKey2Proposal) key2Proposal;
    }

    //////////////////// constant

    //////////////////// local storage
    uint256 public proposalNum;

    // proposalID => proposal;
    mapping(bytes32 => StoreProposal) private _proposals;

    // topicID => topic;
    mapping(bytes32 => StoreTopic) private _topics;

    //////////////////// constructor
    constructor(address addrRegistry) {
        super.init(addrRegistry);
    }

    //////////////////// modifier
    modifier ExistTopic(bytes32 topicID) {
        require(_isTopicExist(topicID), "topic not exist");
        _;
    }

    modifier ExistProposal(bytes32 proposalID) {
        require(_isProposalExist(proposalID), "proposal not exist");
        _;
    }

    modifier IsRegisterDao() {
        require(_isRegisterDao(_msgSender()), "not register dao");
        _;
    }

    //////////////////// public read
    function helpEncodeMetadata(
        string memory key,
        bytes32 typeID,
        bytes memory data,
        string memory desc
    ) public pure returns (bytes memory) {
        return abi.encode(key, typeID, data, desc);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IProposalRegistry).interfaceId;
    }

    //////////////////// topic
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        public
        view
        override
        ExistTopic(topicID)
        returns (bytes32 proposalID)
    {
        StoreTopic storage topic = _topics[topicID];

        return
            topic.key2Proposal[LEnumerableMetadata._getKeyID(key)].proposalID;
    }

    function getTopicMetadata(bytes32 topicID, string memory key)
        public
        view
        override
        returns (
            // ExistTopic(topicID)
            bytes32 typeID,
            bytes memory data
        )
    {
        bytes32 proposalID = getTopicKeyProposal(topicID, key);
        if (!_isProposalExist(proposalID)) {
            return (typeID, data);
        }

        return getProposalKvData(proposalID, key);
    }

    // use enumerable map to store metadata
    function getTopicMetadataKeys(
        bytes32 topicID,
        string memory startKey,
        uint256 pageSize
    ) public view override ExistTopic(topicID) returns (string[] memory keys) {
        StoreTopic storage topic = _topics[topicID];

        bytes32 nowProposalID;
        uint256 proposalIdx;
        if (bytes(startKey).length == 0) {
            proposalIdx = topic.proposalIDs.length - 1;
            nowProposalID = topic.proposalIDs[proposalIdx];
        } else {
            bytes32 keyID = LEnumerableMetadata._getKeyID(startKey);
            TopicKey2Proposal storage keymap = topic.key2Proposal[keyID];
            nowProposalID = keymap.proposalID;
            proposalIdx = keymap.proposalIdx;
        }

        require(topic.proposalIDs[proposalIdx] == nowProposalID, "code err");

        keys = new string[](pageSize);
        uint256 idx = 0;
        while (idx < pageSize && _isProposalExist(nowProposalID)) {
            string[] memory proposalKeys;
            if (idx > 0) {
                proposalKeys = getProposalKvDataKeys(
                    nowProposalID,
                    startKey,
                    pageSize - idx
                );
            } else {
                proposalKeys = getProposalKvDataKeys(
                    nowProposalID,
                    "",
                    pageSize - idx
                );
            }

            for (uint256 i = 0; i < proposalKeys.length; i++) {
                if (
                    topic
                        .key2Proposal[
                            LEnumerableMetadata._getKeyID(proposalKeys[i])
                        ]
                        .proposalID == nowProposalID
                ) {
                    keys[idx] = proposalKeys[i];
                    idx++;
                }
            }

            if (proposalIdx == 0) {
                break;
            }
            proposalIdx--;
            nowProposalID = topic.proposalIDs[proposalIdx];
        }

        assembly {
            mstore(keys, idx)
        }

        return keys;
    }

    // encode(string key, bytes32 class, bytes value)
    function getTopicAllMetadata(
        bytes32 topicID,
        string memory startKey,
        uint256 pageSize
    ) public view override ExistTopic(topicID) returns (bytes[] memory kvData) {
        string[] memory keys = getTopicMetadataKeys(
            topicID,
            startKey,
            pageSize
        );

        kvData = new bytes[](keys.length);

        for (uint256 i = 0; i < keys.length; i++) {
            (bytes32 typeID, bytes memory data) = getTopicMetadata(
                topicID,
                keys[i]
            );
            kvData[i] = abi.encode(keys[i], typeID, data);
        }

        return kvData;
    }

    function getTopicInfo(bytes32 topicID)
        public
        view
        override
        ExistTopic(topicID)
        returns (Topic memory topic)
    {
        StoreTopic storage r = _topics[topicID];

        topic.topicID = r.topicID;
        topic.proposalIDs = r.proposalIDs;
        topic.dao = r.dao;

        return topic;
    }

    //////////////////// proposal

    function getProposalSummary(bytes32 proposalID)
        public
        view
        override
        ExistProposal(proposalID)
        returns (Proposal memory proposal)
    {
        StoreProposal storage p = _proposals[proposalID];

        proposal.status = p.status;
        proposal.proposalID = p.proposalID;
        proposal.topicID = p.topicID;
        proposal.dao = p.dao;

        return proposal;
    }

    function getProposalMetadata(bytes32 proposalID, string memory key)
        public
        view
        override
        ExistProposal(proposalID)
        returns (bytes32 typeID, bytes memory data)
    {
        return _proposals[proposalID].metadata._getByKey(key);
    }

    function getProposalKvData(bytes32 proposalID, string memory key)
        public
        view
        override
        ExistProposal(proposalID)
        returns (bytes32 typeID, bytes memory data)
    {
        return _proposals[proposalID].kvData._getByKey(key);
    }

    function getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    )
        public
        view
        override
        ExistProposal(proposalID)
        returns (string[] memory keys)
    {
        StoreProposal storage proposal = _proposals[proposalID];

        return proposal.kvData._getAllKeys(startKey, pageSize);
    }

    function getProposalAllMetadata(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    )
        public
        view
        override
        ExistProposal(proposalID)
        returns (bytes[] memory kvData)
    {
        StoreProposal storage proposal = _proposals[proposalID];

        return proposal.metadata._getAll(startKey, pageSize);
    }

    //////////////////// exec

    function newProposal(ProposalApplyInfo memory proposal, bytes memory)
        public
        override
        IsRegisterDao
        returns (bytes32 proposalID)
    {
        proposalNum++;
        proposalID = keccak256(abi.encode(_msgSender(), proposalNum));

        StoreProposal storage p = _proposals[proposalID];

        p.status = ProposalStatus.PENDING;
        p.proposalID = proposalID;
        p.dao = _msgSender();
        p.metadata._init();
        p.metadata._setBytesSlice(proposal.headers);
        p.kvData._init();
        p.kvData._setBytesSlice(proposal.items);
        _setTopicID(p);

        emit ENewProposal(
            _msgSender(),
            proposalID,
            proposal.headers,
            proposal.items
        );
        return proposalID;
    }

    // used to append new kvData(can convert old same key)
    function changeProposal(
        bytes32 proposalID,
        bytes[] memory kvData,
        bytes memory
    ) public override ExistProposal(proposalID) IsRegisterDao {
        StoreProposal storage p = _proposals[proposalID];
        require(p.dao == _msgSender(), "dao error");
        require(p.status == ProposalStatus.PENDING, "proposal status err");

        p.kvData._setBytesSlice(kvData);

        emit EProposalAppend(_msgSender(), proposalID, kvData);
    }

    // if agree, apply the proposal kvdata to topic.
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes memory
    ) public override ExistProposal(proposalID) IsRegisterDao {
        StoreProposal storage p = _proposals[proposalID];
        require(p.dao == _msgSender(), "dao error");
        require(p.status == ProposalStatus.PENDING, "proposal status err");

        if (!agree) {
            p.status = ProposalStatus.DENY;
            emit EProposalDecide(_msgSender(), proposalID, agree, bytes32(0x0));
            return;
        }

        p.status = ProposalStatus.AGREE;

        bytes32 topicID;
        if (p.topicID == bytes32(0x0)) {
            topicID = keccak256(abi.encode(proposalID));
        } else {
            topicID = p.topicID;
        }

        StoreTopic storage t = _topics[topicID];
        if (p.topicID == bytes32(0x0)) {
            // new
            p.topicID = topicID;

            t.topicID = topicID;
            t.dao = _msgSender();
            emit ETopicCreate(_msgSender(), topicID, proposalID);
        } else {
            emit ETopicFix(_msgSender(), topicID, proposalID);
        }

        t.proposalIDs.push();
        uint256 newIdx = t.proposalIDs.length - 1;
        t.proposalIDs[newIdx] = proposalID;

        string[] memory keys = getProposalKvDataKeys(
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

        emit EProposalDecide(_msgSender(), proposalID, agree, topicID);
    }

    //////////////////// private func
    function _isRegisterDao(address dao)
        private
        view
        returns (bool isRegistered)
    {
        // return addrRegistry.checkAddressTag(dao, AddressTag.FACTORY_DAO);
    }

    function _setTopicID(StoreProposal storage p) private {
        (, bytes memory data) = p.metadata._get(MetadataKeyID.TOPIC_ID);
        if (data.length == 0) {
            return;
        }

        bytes32 topicID = abi.decode(data, (bytes32));

        require(_isTopicExist(topicID), "not have topic");
        require(
            _topics[topicID].dao == _msgSender(),
            "can't fix other dao topic"
        );

        p.topicID = topicID;
    }

    function _isTopicExist(bytes32 topicID) private view returns (bool) {
        if (topicID == bytes32(0x0)) {
            return false;
        }

        if (_topics[topicID].topicID == bytes32(0x0)) {
            return false;
        }

        return true;
    }

    function _isProposalExist(bytes32 proposalID) private view returns (bool) {
        if (proposalID == bytes32(0x0)) {
            return false;
        }

        if (_proposals[proposalID].proposalID == bytes32(0x0)) {
            return false;
        }

        return true;
    }
}
