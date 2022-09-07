//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IProposalInfo.sol";

/// @title IDAOHandleProposal
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice inteface which defined how to deal with the vote process
interface IProposalHandler is IProposalInfo {
    struct CommitteeInfo {
        bytes32 step;
        address committee;
        uint256 sensitive;
    }

    struct DAOProcessInfo {
        bytes32 proposalID;
        // processCategory is used to distinguish different processes in dao.
        bytes32 processCategory;
        // now decide committee;
        CommitteeInfo nextCommittee;
        // last committee operation time.
        uint256 lastOperationTimestamp;
        // According to the processCategory, order to participate committee.
        // first committee is the launcher committee.
        CommitteeInfo[] committees;
    }

    //////////////////// proposal info

    function getDAOProcessInfo(bytes32 proposalID)
        external
        view
        returns (DAOProcessInfo memory info);

    function getNextCommittee(bytes32 proposalID)
        external
        view
        returns (CommitteeInfo memory nextInfo);

    function getLastOperationTimestamp(bytes32 proposalID)
        external
        view
        returns (uint256 timestamp);

    function getProposalStep(bytes32 proposalID, uint256 stepIdx)
        external
        view
        returns (CommitteeInfo memory stepInfo);
}
