//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IProposalInfo.sol";

error ThisCommitteeDoesNotSupportThisAction();
error ThisCommitteeCannotMakeProposal();

interface ICommittee is IProposalInfo, IERC165 {
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

    // function vote(
    //     VoteIdentity calldata identity,
    //     bool agree,
    //     uint256 count,
    //     string calldata feedback,
    //     bytes calldata data
    // ) external;

    /// @notice for
    /// @dev create proposal start point, and the committee
    /// will call DAO's new proposals and actually create the proposal
    function newProposal(NewProposalInfo calldata proposal, bytes calldata data)
        external
        returns (bytes32 proposalID);

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
