//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "../utils/ConfigHelper.sol";

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

    /// @dev batch setting the admin key
    /// @param adminKeys admin's key
    function batchSetAdminKeys(ConfigHelper.AdminKeyInfo[] memory adminKeys)
        external;

    /// @dev batch setting prefix
    /// @param prefixKeyInfo prefix key infos
    function batchSetPrefixKeyAdmin(
        ConfigHelper.AdminKeyPrefixInfo[] memory prefixKeyInfo
    ) external;

    /// @dev batch set key and values
    /// @param domain target domain
    /// @param kvs array, referal to KVInfo structs
    function batchSetKV(address domain, ConfigHelper.KVInfo[] memory kvs)
        external;

    /// @dev get typeID and data of the key
    /// @param key the key of data
    /// @return typeID key's typeID
    /// @return data key's data
    function getKV(bytes32 key)
        external
        view
        returns (bytes32 typeID, bytes memory data);

    /// @dev help frontend to build key consistantly
    /// @param domain wallet public key
    /// @param prefix prefix, could be empty
    /// @param keyName key name
    function buildConfigKey(
        address domain,
        string memory prefix,
        string memory keyName
    ) external pure returns (bytes32 key);
}
