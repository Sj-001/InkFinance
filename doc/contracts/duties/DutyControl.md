# DutyControl





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### addDuty
Duty Related

> add user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function addDuty(
bytes32 dutyID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | user-defined dutyID, formed by keccak256


### remmoveDuty

> remove user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function remmoveDuty(
bytes32 dutyID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | user-defined dutyID, formed by keccak256


### addUser

> add user into the DAO, !!! Agent call only


*Declaration:*
```solidity
function addUser(
address account
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | target user


### removeUser

> remove user from the DAO, !!! Agent call only


*Declaration:*
```solidity
function removeUser(
address account
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | target user


### hasDuty

> identity the account have the duty or not


*Declaration:*
```solidity
function hasDuty(
address account,
bytes32 dutyID
) external returns
(bool exist)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | the query account
|`dutyID` | bytes32 | the target duty

*Returns:*
| Arg | Description |
| --- | --- |
|`exist` | exist or not

### getDutyOwners

> find out how many users have this duty


*Declaration:*
```solidity
function getDutyOwners(
bytes32 dutyID,
 owners
) external returns
(uint256 owners)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | target duty
|`owners` |  | amount of the duty owner


### getDutyOwnerByIndex

> get duty holder's address by index, this used to enumerate all user‘s have this duty


*Declaration:*
```solidity
function getDutyOwnerByIndex(
bytes32 dutyID,
uint256 index
) external returns
(address addr)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | target duty
|`index` | uint256 | index place

*Returns:*
| Arg | Description |
| --- | --- |
|`addr` | the address at that index

## 5.Events
