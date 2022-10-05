//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LEnumerableMetadata.sol";

/// @title IDAOHandleProposal
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice struct and events definations related to proposal
interface IProposalInfo {
    /// @notice when new proposal generated, this event will be emit
    event NewProposal(
        bytes32 indexed proposalID,
        bytes[] metadata,
        bytes[] kvData
    );

    /// @notice when kvData has been add to the proposal this event will be emit
    /// @dev kvData if the key is the same, the value will be override
    event ProposalAppend(bytes32 indexed proposalID, bytes[] kvData);

    /// @notice once proposal decided, this emit will be emit
    /// @param dao from which dao;
    /// @param proposalID proposalID
    /// @param agree true=ageree, false=disagree
    /// @param topicID the topic of the proposal
    event ProposalDecide(
        address indexed dao,
        bytes32 indexed proposalID,
        bool indexed agree,
        bytes32 topicID
    );

    /// @dev once propsal decided this event will be emit
    event ProposalTopicSynced(
        bytes32 indexed proposalID,
        bool indexed agree,
        bytes32 topicID
    );

    event TopicCreate(bytes32 indexed topicID, bytes32 indexed proposalID);

    event TopicFix(bytes32 indexed topicID, bytes32 indexed proposalID);

    /// @dev sub item of NewProposal
    struct KVItem {
        string key;
        bytes32 typeID;
        bytes data;
        bytes desc;
    }

    /// @dev data structure of submiting a new proposal
    /// @param agents agents of the proposal
    /// @param topicID topic of the proposal
    /// @param crossChainProtocal if it's empty, means work on local chain
    /// @param kvData proposal contents
    /// @param metadata proposal metadata
    struct NewProposalInfo {
        bytes32[] agents;
        bytes32 topicID;
        bytes crossChainProtocal;
        KVItem[] metadata;
        bytes[] kvData;
        // require vote options
    }

    // 接口返回格式
    struct Topic {
        bytes32 topicID;
        bytes32[] proposalIDs;
    }

    struct ProposalSummary {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        bytes32 agents;
    }

    //PREPARING,
    enum ProposalStatus {
        PENDING,
        AGREE,
        DENY
    }

    // value的存储结构.
    struct ItemValue {
        bytes32 typeID;
        bytes data;
    }

    struct Proposal {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        bytes32[] agents;
        uint256 nextExecAgentIdx;
        bytes32 crossChainProtocol;
        // 避免链上枚举, 消耗gas, 浪费存储.
        // LEnumerableMetadata.MetadataSet headers;
        mapping(string => ItemValue) metadata;
        // 需要枚举.
        LEnumerableMetadata.MetadataSet kvData;
    }

    // topic中的key落到proposal中的最新位置, 用于加速查询, 类似做索引.
    struct TopicKey2Proposal {
        bytes32 proposalID;
        uint256 proposalIdx;
    }

    // topic存储结构.
    struct TopicProposal {
        bytes32 topicID;
        // 记录所有通过的proposal.
        bytes32[] proposalIDs;
        // 缓存索引系统, proposal通过后, 需要调用索引刷新, 来针对每个key, 存储该值最终的proposalID.
        // 获取proposalID后, 即可通过proposal获取该key对应的值.
        // 刷新缓存时, 可能遇到proposal内的content过多, 此时需要人工介入分段刷新.
        // keyid => latest proposal
        mapping(bytes32 => TopicKey2Proposal) key2Proposal;
        bytes32 lastIndexedProposalID;
        bytes32 lastIndexedKey;
    }
}
