//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IVoteHandler.sol";

library LVoteIdentityHelper {
    function _getIdentityID(IVoteHandler.VoteIdentity memory identity)
        internal
        pure
        returns (bytes32 id)
    {
        return _getIdentityID(identity.proposalID, identity.step);
    }

    function _getIdentityID(bytes32 proposalID, bytes32 step)
        internal
        pure
        returns (bytes32 id)
    {
        return keccak256(abi.encode(proposalID, step));
    }
}
