//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IProposalInfo.sol";

error OnlyDAOCouldOperate(address expectedDAO, address actualOperator);

/// @title IDAOHandleProposal
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice inteface which defined how to deal with the vote process
interface IProposalHandler is IProposalInfo {
    /// @dev created for ProposalHelper to form data easily
    struct TypeData {
        bytes32 typeID;
        bytes data;
    }

    /// @dev when proposal create, the submited data structure
    /// @param name the name of the Committee
    /// @param step the step identity of that committee in the workflow
    /// @param addressConfigKey the committee address key in the ConfigManager
    /// @param committeeAddress contract address of the committee
    /// @param dutyIDs the dutyIDs of the committee
    struct CommitteeCreateInfo {
        string committeeName;
        bytes32 step;
        bytes32 addressConfigKey;
        bytes dutyIDs;
    }

    /// @dev committee info stored for the progress control
    /// @param step the step identity of that committee in the workflow
    /// @param committee contract address of the committee
    /// @param dutyIDs the dutyIDs of the committee
    struct CommitteeInfo {
        bytes32 step;
        address committee;
        string name;
        bytes dutyIDs;
    }

    /// @dev when generate a DAO, the workflow of the DAO proposal should be defined here
    /// @param flowID the workflow ID
    /// @param committees related committees in that workflow
    struct FlowInfo {
        bytes32 flowID;
        CommitteeCreateInfo[] committees;
    }

    /// @dev data structure stored the progress of the proposal
    /// @param proposalID the target proposal
    /// @param flowID the flowID (vote order between all the committees)
    /// @param nextCommittee next committee
    /// @param lastOperationTimestamp last committee operate time
    /// @param committees all the committees in the flow
    struct ProposalProgress {
        bytes32 proposalID;
        // flowID is used to distinguish different processes in dao.
        bytes32 flowID;
        bytes32[] agents;
        // now decide committee;
        CommitteeInfo nextCommittee;
        // last committee operation time.
        uint256 lastOperationTimestamp;
        // According to the flowID, order to participate committee.
        // first committee is the launcher committee.
        CommitteeInfo[] committees;
    }

    event ExecuteOffchainMessage(
        bytes32 indexed topicID,
        address indexed addr,
        bytes32 indexed execProposalID,
        address dao,
        bytes32 nowProposalID,
        bytes message,
        uint256 executeTime
    );

    function getTallyVoteRules(bytes32 proposalID)
        external
        view
        returns (
            uint256 minAgreeRatio,
            uint256 minEffectiveVotes,
            uint256 minEffectiveWallets
        );

    function getProposalFlow(bytes32 proposalID)
        external
        view
        returns (bytes32 flowID);

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

    /// @notice makeing a new proposal
    /// @dev making a new proposal and generate proposal records in the DAO
    /// @param proposal content of the proposal
    /// @param commit if proposal content is huge, the frontend could set commit as False, and submit multiple times
    /// @param proposer who make the proposal
    /// @param data support data, decide by case
    /// @return proposalID generated proposal id
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        address proposer,
        bytes calldata data
    ) external returns (bytes32 proposalID);

    // used to append new kvData(can convert old same key)
    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external;

    // if agree, apply the proposal kvdata to topic.
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external;

    // which proposal decide the latest key item;
    function getTopicKeyProposal(bytes32 topicID, string memory key)
        external
        view
        returns (bytes32 proposalID);

    function getTopicMetadata(bytes32 topicID, string memory key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    function getTopicKVdata(bytes32 topicID, string memory key)
        external
        view
        returns (
            // ExistTopic(topicID)
            bytes32 typeID,
            bytes memory data
        );

    function getTopicInfo(bytes32 topicID)
        external
        view
        returns (Topic memory topic);

    //////////////////// proposal

    /// @dev get proposal's topic, so anyone could create a new proposal with the same topic
    function getProposalTopic(bytes32 proposalID)
        external
        view
        returns (bytes32 topicID);

    function getProposalSummary(bytes32 proposalID)
        external
        view
        returns (ProposalSummary memory proposal);

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

    function flushTopicIndex(bytes32 topicID, uint256 operateNum) external;

    /// @dev off-chain proposal only
    /// @notice when off-chain proposal passed, dao admin could upload some text approve the proposal has been executed.
    function execProposalMessage(bytes32 proposalID, bytes memory messages)
        external;

    function getNextVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        returns (CommitteeInfo memory committeeInfo);

    function getVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        returns (address committee, bytes32 step);

    function getVotedCommittee(bytes32 proposalID)
        external
        view
        returns (address[] memory committee);

    function getVoteExpirationTime(bytes32 proposalID)
        external
        view
        returns (uint256 expiration);

    function getFlowSteps(bytes32 flowID)
        external
        view
        returns (CommitteeInfo[] memory infos);

    function setFlowStep(FlowInfo memory flow) external;

    function getSupportedFlow() external view returns (bytes32[] memory flows);
}
