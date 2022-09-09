//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LEnumerableMetadata.sol";

/// @title IDAOHandleProposal
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice inteface which defined how to deal with the vote process
interface IProposalInfo {
    // one bytes[] item is encode(string key, bytes32 typeID, bytes value, string describe)
    // describe field just used in event log, not stored in the slot.
    struct ProposalApplyInfo {
        bytes[] items;
        bytes[] headers;
    }
    // 接口返回格式
    struct Topic {
        bytes32 topicID;
        bytes32[] proposalIDs;
    }

    struct Proposal {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        bytes32 agents;
    }

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

    struct StoreProposal {
        ProposalStatus status;
        bytes32 proposalID;
        bytes32 topicID;
        bytes32[] agents;
        uint256 nextExecAgentIdx;
        bytes32 crossChainProtocol;
        // 避免链上枚举, 消耗gas, 浪费存储.
        mapping(bytes32 => ItemValue) metaData;
        // 需要枚举.
        LEnumerableMetadata.MetadataSet kvData;
    }

    // topic中的key落到proposal中的最新位置, 用于加速查询, 类似做索引.
    struct TopicKey2Proposal {
        bytes32 proposalID;
        uint256 proposalIdx;
    }

    // topic存储结构.
    struct StoreTopic {
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
