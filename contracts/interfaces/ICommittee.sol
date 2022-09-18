//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IProposalInfo.sol";
import "./IVoteHandler.sol";

error ThisCommitteeDoesNotSupportThisAction();
error ThisCommitteeCannotMakeProposal();

interface ICommittee is IProposalInfo, IVoteHandler, IERC165 {
    /// @notice return committee's duties
    /// @return duties committee's duties
    function getCommitteeDuties() external returns (bytes32[] memory duties);

    // /// @dev release special vote process locked pledge votes.
    // function releaseGovernancePledge(VoteIdentity memory identity) external;

    /// @dev get the pledge info.
    // function getProposalPledgeInfo(VoteIdentity memory identity, address user)
    //     external
    //     view
    //     returns (PledgeInfo memory pledgeInfo);

    //////////////////// exec proposal

    /// @notice makeing a new proposal
    /// @dev Committee doesn't create propsal, DAO is the contract creating proposal, the committee just maintain the relationship between the propsal and committee and creator.
    /// @param proposal content of the proposal
    /// @param commit if proposal content is huge, the frontend could set commit as False, and submit multiple times
    /// @param data support data, decide by case
    /// @return proposalID generated proposal id
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) external returns (bytes32 proposalID);

    /// @dev verify the user has the permission to vote
    function allowOperate(VoteIdentity calldata identity, address user)
        external
        view
        returns (bool isAllow);

    // // kvData item is encode(string key, bytes32 typeID, bytes value, string describe)
    // function changeProposal(
    //     VoteIdentity calldata identity,
    //     bytes[] calldata kvData,
    //     bytes calldata data
    // ) external;

    // function decideProposal(VoteIdentity calldata identity, bytes calldata data)
    //     external;

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
