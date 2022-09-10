//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IConfig.sol";
import "hardhat/console.sol";

/// @dev ConfigManager is a Key/Value management contract based on domain.
/// domain here basic means wallet public key
/// anyone could add keys under their wallet and invite other wallet to manage the key under their own.
/// here is key variable's explaination:
/// 1. domain = wallet public key
/// 2. key = keccak256(domain + keyID)
/// 3. keyID = keccak256(keccak256(<prefix>) + keccak256(keyName))
/// todo INk admin area, multi-sign management
contract ConfigManager is IConfig {
    /// libs
    using EnumerableSet for EnumerableSet.AddressSet;
    using ConfigHelper for mapping(bytes32 => ConfigHelper.KVInfo);
    using ConfigHelper for mapping(bytes32 => mapping(bytes32 => EnumerableSet.AddressSet));
    using ConfigHelper for mapping(bytes32 => mapping(string => EnumerableSet.AddressSet));

    /// @dev all key's value have been stored under their domain, so they are isolated physically.
    /// bytes32(keccak256(domain + prefix + keyName) => bytes(value of the key)
    mapping(bytes32 => ConfigHelper.KVInfo) private _domainKeyValues;

    /// domain=>keyID=>admin address set
    mapping(bytes32 => mapping(bytes32 => EnumerableSet.AddressSet))
        private _domainKeyAdmins;

    /// domain=>prefix=>admin address set
    mapping(bytes32 => mapping(string => EnumerableSet.AddressSet))
        private _domainPrefixAdmins;

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {
        return interfaceId == type(IConfig).interfaceId;
    }

    constructor() {}

    /// @inheritdoc IConfig
    function buildConfigKey(
        address domain,
        string memory prefix,
        string memory keyName
    ) external override pure returns (bytes32 key) {
        key = ConfigHelper.packKey(domain, prefix, keyName);
    }

    /// @inheritdoc IConfig
    function batchSetAdminKeys(ConfigHelper.AdminKeyInfo[] memory adminKeyInfos)
        external
        override
    {
        for (uint256 i = 0; i < adminKeyInfos.length; i++) {
            _domainKeyAdmins.addAdminManageableKey(adminKeyInfos[i]);
            // event SetConfigAdmin(
            //     address indexed domain,
            //     bytes32 indexed keyID,
            //     address indexed admin
            // );
            
        }
    }

    /// @inheritdoc IConfig
    function batchSetPrefixKeyAdmin(
        ConfigHelper.AdminKeyPrefixInfo[] memory prefixKeyInfo
    ) external override {
        for (uint256 i = 0; i < prefixKeyInfo.length; i++) {
            _domainPrefixAdmins.addAdminManageableKeyPrefix(prefixKeyInfo[i]);
            // event SetPrefixConfigAdmin(
            //     address indexed domain,
            //     string indexed keyPrefix,
            //     address indexed admin
            // );
        }
    }

    /// @inheritdoc IConfig
    function batchSetKV(
        address domain,
        ConfigHelper.KVInfo[] memory keyValueInfos
    ) external override {
        for (uint256 i = 0; i < keyValueInfos.length; i++) {
            if (
                hasRightToSet(
                    domain,
                    keyValueInfos[i].keyPrefix,
                    keyValueInfos[i].keyName
                )
            ) {
                _domainKeyValues.addKeyValue(domain, keyValueInfos[i]);

                // event SetKV(
                //     address indexed operator,
                //     address indexed domain,
                //     bytes32 indexed key,
                //     string keyPrefix,
                //     string keyName,
                //     bytes32 typeID,
                //     bytes data
                // );

            } else {
                console.log("no right to set key's value");
            }
        }
    }

    /// @inheritdoc IConfig
    function getKV(bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {
        ConfigHelper.KVInfo memory info = _domainKeyValues[key];
        typeID = info.typeID;
        data = info.data;
    }

    /// @notice verify the msgSender has the right to update the value under that domain
    function hasRightToSet(
        address domain,
        string memory prefix,
        string memory keyName
    ) internal view returns (bool hasRight) {
        if (domain == msg.sender) {
            return true;
        }

        bytes32 domainHash = ConfigHelper.getAddressHash(domain);

        if (_domainPrefixAdmins[domainHash][prefix].contains(msg.sender)) {
            return true;
        }

        if (
            _domainKeyAdmins[domainHash][
                ConfigHelper.packKeyID(prefix, keyName)
            ].contains(msg.sender)
        ) {
            return true;
        }

        return false;
    }
}
