//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IProposalRegistryInfo
/// @author InkTech <tech-support@inkfinance.xyz>
interface IProposalRegistryInfo {
    enum ProposalStatus {
        PENDING,
        AGREE,
        DENY
    }

    struct Topic {
        bytes32 topicID;
        bytes32[] proposalIDs;
        // current dao.
        address dao;
    }

    struct Proposal {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        // if one dao was upgraded, the dao addr is the origin address.
        address dao;

        // proposal self metadata;
        // mapping(string => (bytes32 type, bytes data));

        // proposal kv data;
        // mapping(string => (bytes32 type, bytes data));
    }

    //////////////////// topic
    // which proposal decide the latest key item;
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        external
        view
        returns (bytes32 proposalID);

    function getTopicMetadata(bytes32 topicID, string memory key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    // use enumerable map to store metadata
    function getTopicMetadataKeys(
        bytes32 topicID,
        string memory startKey,
        uint256 pageSize
    ) external view returns (string[] memory keys);

    // encode(string key, bytes32 type, bytes value)
    function getTopicAllMetadata(
        bytes32 topicID,
        string memory startKey,
        uint256 pageSize
    ) external view returns (bytes[] memory kvData);

    function getTopicInfo(bytes32 topicID)
        external
        view
        returns (Topic memory topic);

    //////////////////// proposal

    function getProposalSummary(bytes32 proposalID)
        external
        view
        returns (Proposal memory proposal);

    function getProposalMetadata(bytes32 proposalID, string memory key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getProposalKvData(bytes32 proposalID, string memory key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getProposalKvDataKeys(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) external view returns (string[] memory keys);

    function getProposalAllMetadata(
        bytes32 proposalID,
        string memory startKey,
        uint256 pageSize
    ) external view returns (bytes[] memory kvData);
}
