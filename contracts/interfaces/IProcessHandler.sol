//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IProcessHandler
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice take controler of the vote information and vote progress
interface IProcessHandler {
    /// @notice return the expiratin time of the proposal's step
    /// @dev the expiration period was stored in the metadata, and key is Expiration
    /// but it is just stored period, the actual date time should be add the last operatie time
    /// for eg: every time the new proposal post or one committee stage had be decided, the operation time would be reset at that moment
    function getVoteExpirationTime(bytes32 proposalID)
        external
        view
        returns (uint256 expiration);
}
