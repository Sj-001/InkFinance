//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
/// @dev 管理所有成员的元数据.
///      每个地址都可以针对每个用户设置kv数据, "每个地址"代表作用域, 可以由外 部合约指定要读取哪个作用域下的用户设置.
///      核心用于用户kyc时, 不同机构可以对同一个用户指定不同值, 由外部决定采 用哪个机构的数据.

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

    // 仅能设置到msg.sender地址下的作用域中.
    function batchSetUserKVs(UserKV[] memory kvs) external;

    function getUserKV(address zone, bytes32 key)
        external
        returns (bytes32 typeID, bytes memory data);
}
