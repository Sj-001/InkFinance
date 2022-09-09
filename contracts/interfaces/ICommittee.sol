//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IProposalInfo.sol";

interface ICommittee is IProposalInfo, IERC165 {
    struct KVItem {
        bytes32 key;
        bytes32 typeID;
        bytes data;
    }

    function newProposal(
        Proposal calldata proposal,
        bool commit,
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

    // function addDutyID() external;

    // function getDuties() external;

    // function addDuties() external;

    // /// @dev release special vote process locked pledge votes.
    // function releaseGovernancePledge(VoteIdentity memory identity) external;

    /// @dev get the pledge info.
    // function getProposalPledgeInfo(VoteIdentity memory identity, address user)
    //     external
    //     view
    //     returns (PledgeInfo memory pledgeInfo);

    //////////////////// exec proposal

    // function vote(
    //     VoteIdentity calldata identity,
    //     bool agree,
    //     uint256 count,
    //     string calldata feedback,
    //     bytes calldata data
    // ) external;

    // function newProposal(
    //     address dao,
    //     ProposalApplyInfo calldata proposal,
    //     bytes calldata data
    // ) external returns (bytes32 proposalID);

    // // kvData item is encode(string key, bytes32 typeID, bytes value, string describe)
    // function changeProposal(
    //     VoteIdentity calldata identity,
    //     bytes[] calldata kvData,
    //     bytes calldata data
    // ) external;

    // function decideProposal(VoteIdentity calldata identity, bytes calldata data)
    //     external;

    //////////////////// exec member

    // voteCount == 0: delete
    // > 0: add or resetting
    // function memberSetting(
    //     address member,
    //     uint256 voteNum,
    //     bytes calldata data
    // ) external;

    // function getVoteExpiration(VoteIdentity memory identity)
    //     external
    //     view
    //     returns (uint256);
}
