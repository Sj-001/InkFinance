//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
interface IIdentity is IERC165 {
    struct UserKV {
        address user;
        bytes32 key;
        bytes32 typeID;
        bytes data;
    }
    //////////// 存储示例
    struct Value {
        bytes32 typeID;
        bytes data;
    }

    struct KVZone {
        address issue;
        // user -> key -> value
        mapping(address => mapping(bytes32 => Value)) kvs;
    }

    
    function batchSetUserKVs(UserKV[] memory kvs) external;

    function getUserKV(address zone, bytes32 key)
        external
        returns (bytes32 typeID, bytes memory data);
}
