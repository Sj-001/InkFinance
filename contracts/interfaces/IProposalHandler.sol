//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IProposalInfo.sol";

/// @title IDAOHandleProposal
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice inteface which defined how to deal with the vote process
interface IProposalHandler is IProposalInfo {
    struct CommitteeInfo {
        bytes32 step;
        string committeeContractID;
        uint256 sensitive;
    }

    // struct DAOProcessInfo {
    //     bytes32 proposalID;
    //     // processCategory is used to distinguish different processes in dao.
    //     bytes32 processCategory;
    //     // now decide committee;
    //     CommitteeInfo nextCommittee;
    //     // last committee operation time.
    //     uint256 lastOperationTimestamp;
    //     // According to the processCategory, order to participate committee.
    //     // first committee is the launcher committee.
    //     CommitteeInfo[] committees;
    // }

    // //////////////////// proposal info

    // function getDAOProcessInfo(bytes32 proposalID)
    //     external
    //     view
    //     returns (DAOProcessInfo memory info);

    // function getNextCommittee(bytes32 proposalID)
    //     external
    //     view
    //     returns (CommitteeInfo memory nextInfo);

    // function getLastOperationTimestamp(bytes32 proposalID)
    //     external
    //     view
    //     returns (uint256 timestamp);

    // function getProposalStep(bytes32 proposalID, uint256 stepIdx)
    //     external
    //     view
    //     returns (CommitteeInfo memory stepInfo);

    struct FlowInfo {
        bytes32 flowID;
        CommitteeInfo[] committees;
    }

    // which proposal decide the latest key item;
    function getTopicKeyProposal(bytes32 topicID, bytes32 key)
        external
        view
        returns (bytes32 proposalID);

    function getTopicMetadata(bytes32 topicID, bytes32 key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getTopicInfo(bytes32 topicID)
        external
        view
        returns (Topic memory topic);

    //////////////////// proposal

    function getProposalSummary(bytes32 proposalID)
        external
        view
        returns (Proposal memory proposal);

    function getProposalMetadata(bytes32 proposalID, bytes32 key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getProposalKvData(bytes32 proposalID, bytes32 key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getProposalKvDataKeys(
        bytes32 proposalID,
        bytes32 startKey,
        uint256 pageSize
    ) external view returns (bytes32[] memory keys);

    //////////////////// flush index
    // dao查看该topicID上次刷新到的位置(lastIndexedProposalID, lastIndexedKey), 来继续进行, 所以权限问题.
    function flushTopicIndex(bytes32 topicID, uint256 operateNum) external;
}
