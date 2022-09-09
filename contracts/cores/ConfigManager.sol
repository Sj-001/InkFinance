//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IConfig.sol";

contract ConfigManager is IConfig {
    // 仅能配置该地址域下的key的管理员.

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {
        return true;
    }

    function batchSetAdminKeys(AdminKeyInfo[] memory adminKeyInfos)
        external
        override
    {}

    function batchSetPrefixKeyAdmin(AdminKeyPrefixInfo[] memory prefixKeyInfo)
        external
        override
    {}

    function batchSetKV(address domain, KVInfo[] memory kvs)
        external
        override
    {}

    function getKV(bytes32 key)
        external
        override
        returns (bytes32 typeID, bytes memory data)
    {}
}
