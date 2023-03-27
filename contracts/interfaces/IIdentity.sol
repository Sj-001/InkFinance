//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

struct UserKV {
    address user;
    string key;
    bytes32 typeID;
    bytes data;
}

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
interface IIdentity is IERC165 {
    /// @dev value stored
    struct Value {
        bytes32 typeID;
        bytes data;
    }

    struct KVZone {
        string issue;
        // user -> key -> value
        mapping(address => mapping(string => Value)) kvs;
    }

    function batchSetUserKVs(string memory zone, UserKV[] memory kvs) external;

    function getUserKV(
        string memory zone,
        address user,
        string memory key
    ) external view returns (bytes32 typeID, bytes memory data);
}
