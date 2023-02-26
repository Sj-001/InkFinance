# ConfigManager



> ConfigManager is a Key/Value management contract based on domain.
domain here basic means wallet public key
anyone could add keys under their wallet and invite other wallet to manage the key under their own.
here is key variable's explaination:
1. domain = wallet public key
2. key = keccak256(domain + keyID)
3. keyID = keccak256(keccak256(<prefix>) + keccak256(keyName))
todo INk admin area, multi-sign management

## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### supportsInterface

> Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.

*Declaration:*
```solidity
function supportsInterface(
) external returns
(bool)
```




### buildConfigKey

> help frontend to build key consistantly


*Declaration:*
```solidity
function buildConfigKey(
address domain,
string prefix,
string keyName
) external returns
(bytes32 key)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`domain` | address | wallet public key
|`prefix` | string | prefix, could be empty
|`keyName` | string | key name


### batchSetAdminKeys

> batch setting the admin key


*Declaration:*
```solidity
function batchSetAdminKeys(
struct ConfigHelper.AdminKeyInfo[] adminKeys
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`adminKeys` | struct ConfigHelper.AdminKeyInfo[] | admin's key


### batchSetPrefixKeyAdmin

> batch setting prefix


*Declaration:*
```solidity
function batchSetPrefixKeyAdmin(
struct ConfigHelper.AdminKeyPrefixInfo[] prefixKeyInfo
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`prefixKeyInfo` | struct ConfigHelper.AdminKeyPrefixInfo[] | prefix key infos


### batchSetKV

> batch set key and values


*Declaration:*
```solidity
function batchSetKV(
address domain,
struct ConfigHelper.KVInfo[] kvs
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`domain` | address | target domain
|`kvs` | struct ConfigHelper.KVInfo[] | array, referal to KVInfo structs


### getKV

> get typeID and data of the key


*Declaration:*
```solidity
function getKV(
bytes32 key
) external returns
(bytes32 typeID, bytes data)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`key` | bytes32 | the key of data

*Returns:*
| Arg | Description |
| --- | --- |
|`typeID` | key's typeID
|`data` | key's data

### hasRightToSet
verify the msgSender has the right to update the value under that domain


*Declaration:*
```solidity
function hasRightToSet(
) internal returns
(bool hasRight)
```




## 5.Events
