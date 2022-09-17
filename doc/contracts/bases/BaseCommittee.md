# BaseCommittee





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| _parentDAO | address |
| committeeDuties | struct EnumerableSet.Bytes32Set |

## 3.Modifiers

## 4.Functions

### supportsInterface



*Declaration:*
```solidity
function supportsInterface(
) public returns
(bool)
```




### _init



*Declaration:*
```solidity
function _init(
) internal
```




### getParentDAO



*Declaration:*
```solidity
function getParentDAO(
) internal returns
(address parentDAO)
```




### getCommitteeDuties
return committee's duties



*Declaration:*
```solidity
function getCommitteeDuties(
) external returns
(bytes32[] duties)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`duties` | committee's duties

## 5.Events
