//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IIdentity.sol";

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
contract IdentityManager is IIdentity {


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IIdentity).interfaceId;
    }

    /// @inheritdoc IIdentity
    function batchSetUserKVs(UserKV[] memory kvs) external override {
        
    }

    /// @inheritdoc IIdentity
    function getUserKV(address zone, bytes32 key)
        external
        override
        returns (bytes32 typeID, bytes memory data)
    {}
}
