//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
}
