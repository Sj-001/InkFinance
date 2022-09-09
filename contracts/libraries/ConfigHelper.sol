//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library ConfigHelper {
    /// @dev only for test
    using EnumerableSet for EnumerableSet.AddressSet;

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

    function getPrefix(string memory _prefix)
        internal
        pure
        returns (string memory)
    {
        if (bytes(_prefix).length == 0) {
            return "_DEFAULT_KEY_PREFIX_";
        }
        return _prefix;
    }

    /// @dev used to pack key
    function packKey(
        address domain,
        string memory prefix,
        string memory keyName
    ) public pure returns (bytes32 key) {
        string memory actualPrefix = getPrefix(prefix);
        bytes32 keyID = packKeyID(actualPrefix, keyName);
        key = keccak256(abi.encodePacked(domain, keyID));
    }

    /// @dev used to pack keyID
    function packKeyID(string memory prefix, string memory keyName)
        public
        pure
        returns (bytes32 keyID)
    {
        string memory actualPrefix = getPrefix(prefix);
        keyID = keccak256(
            abi.encodePacked(
                abi.encodePacked(actualPrefix),
                keccak256(abi.encodePacked(keyName))
            )
        );
    }

    function getAddressHash(address addr)
        public
        pure
        returns (bytes32 addressHash)
    {
        addressHash = keccak256(abi.encodePacked(addr));
    }

    function addKeyValue(
        mapping(bytes32 => KVInfo) storage self,
        address domain,
        KVInfo memory keyInfo
    ) internal {
        bytes32 key = packKey(domain, keyInfo.keyPrefix, keyInfo.keyName);
        self[key] = keyInfo;
    }

    function addAdminManageableKey(
        mapping(bytes32 => mapping(bytes32 => EnumerableSet.AddressSet))
            storage self,
        AdminKeyInfo memory keyInfo
    ) internal {
        bytes32 domainKey = getAddressHash(msg.sender);
        mapping(bytes32 => EnumerableSet.AddressSet)
            storage adminManageableKeys = self[domainKey];
        if (!adminManageableKeys[keyInfo.keyID].contains(keyInfo.admin)) {
            adminManageableKeys[keyInfo.keyID].add(keyInfo.admin);
        }
    }

    function addAdminManageableKeyPrefix(
        mapping(bytes32 => mapping(string => EnumerableSet.AddressSet))
            storage self,
        AdminKeyPrefixInfo memory prefixInfo
    ) internal {
        bytes32 domainKey = getAddressHash(msg.sender);
        mapping(string => EnumerableSet.AddressSet)
            storage adminManageablePrefix = self[domainKey];
        if (
            !adminManageablePrefix[prefixInfo.keyPrefix].contains(
                prefixInfo.admin
            )
        ) {
            adminManageablePrefix[prefixInfo.keyPrefix].add(prefixInfo.admin);
        }
    }
}
