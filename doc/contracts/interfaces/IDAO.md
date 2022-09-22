# IDAO





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### callFromDAO

> let agent call any DAO method


*Declaration:*
```solidity
function callFromDAO(
address contractAddress,
bytes functionSignature
) external returns
(bool success, bytes returnedBytes)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`contractAddress` | address | ask DAO to call the contractAddress
|`functionSignature` | bytes | the function signatures

*Returns:*
| Arg | Description |
| --- | --- |
|`success` | if the call succeed
|`returnedBytes` | the returned bytes from the contract function call

### setupFlowInfo

> add a new workflow, noramll call by agent

*Declaration:*
```solidity
function setupFlowInfo(
) external
```




## 5.Events
