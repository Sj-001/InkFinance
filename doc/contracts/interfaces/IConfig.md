# IConfig





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

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


## 5.Events
### SetConfigAdmin

> when set admin of some domain key, this event will be sent



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`domain` | address | :white_check_mark: | domain of the key
|`keyID` | bytes32 | :white_check_mark: | user defined key
|`admin` | address | :white_check_mark: | admin's address
### SetPrefixConfigAdmin
注: string类型仅用于事件, 合约本地存储用hash后的值.

> when set admin of some domain's key prefix, this event will be sent



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`domain` | address | :white_check_mark: | domain of the key prefix
|`keyPrefix` | string | :white_check_mark: | user defined key prefix
|`admin` | address | :white_check_mark: | admin's address
### SetKV





