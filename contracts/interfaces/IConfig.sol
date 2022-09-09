//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IConfig is IERC165 {
    /// @dev when set admin of some domain key, this event will be sent
    /// @param domain domain of the key
    /// @param keyID user defined key
    /// @param admin admin's address
    event SetConfigAdmin(
        address indexed domain,
        bytes32 indexed keyID,
        address indexed admin
    );

    /// 注: string类型仅用于事件, 合约本地存储用hash后的值.
    /// @dev when set admin of some domain's key prefix, this event will be sent
    /// @param domain domain of the key prefix
    /// @param keyPrefix user defined key prefix
    /// @param admin admin's address
    event SetPrefixConfigAdmin(
        address indexed domain,
        string indexed keyPrefix,
        address indexed admin
    );

    /// @dev Admin's keyID info
    /// @param keyID the keyID
    /// @param admin the admin's address
    struct AdminKeyInfo {
        bytes32 keyID;
        address admin;
    }

    struct AdminKeyPrefixInfo {
        string keyPrefix;
        address admin;
    }

    /// @dev KV item
    /// @param keyPrefix prefix of the key
    /// @param keyName key name
    /// @param typeID the key's type
    /// @param data the data of the key
    struct KVInfo {
        string keyPrefix;
        string keyName;
        bytes32 typeID;
        bytes data;
    }

    /// @dev batch setting the admin key
    /// @param adminKeys admin's key
    function batchSetAdminKeys(AdminKeyInfo[] memory adminKeys) external;

    /// @dev batch setting prefix
    /// @param prefixKeyInfo prefix key infos
    function batchSetPrefixKeyAdmin(AdminKeyPrefixInfo[] memory prefixKeyInfo)
        external;

    // 仅有对应管理员可以设置该key, domain == msg.sender 时具有所有权限.
    // 注: string类型仅用于事件, 合约本地存储用hash后的值.
    // 先查domain == msg.sender.
    // 再查该domain下的keyPrefix的管理员 == msg.sender.
    // 最后查该domain下的 hash(hash("<prefix>"), hash("<key name>")) 的管理员 == msg.sender
    event SetKV(
        address indexed operator,
        address indexed domain,
        bytes32 indexed key,
        string keyPrefix,
        string keyName,
        bytes32 typeID,
        bytes data
    );

    /// @dev batch set key and values
    /// @param domain target domain
    /// @param kvs array, referal to KVInfo structs
    function batchSetKV(address domain, KVInfo[] memory kvs) external;

    /// @dev get typeID and data of the key
    /// @param key the key of data
    /// @return typeID key's typeID
    /// @return data key's data
    function getKV(bytes32 key)
        external
        returns (bytes32 typeID, bytes memory data);
}
