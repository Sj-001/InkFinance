# PayrollExecuteAgent





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### getAgentFlow



*Declaration:*
```solidity
function getAgentFlow(
) external returns
(bytes32 flowID)
```




### init



*Declaration:*
```solidity
function init(
) public returns
(bytes callbackEvent)
```




### preExec

> pre exec mean check the execute process and see if any problems.


*Declaration:*
```solidity
function preExec(
bytes32 proposalID
) external returns
(bool success)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | target proposal

*Returns:*
| Arg | Description |
| --- | --- |
|`success` | true means works

### exec
only DAO could execute

> do run the proposal decision


*Declaration:*
```solidity
function exec(
bytes32 proposalID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | target proposal


### getTypeID



*Declaration:*
```solidity
function getTypeID(
) external returns
(bytes32 typeID)
```




### getVersion



*Declaration:*
```solidity
function getVersion(
) external returns
(uint256 version)
```




### supportsInterface

> Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.

*Declaration:*
```solidity
function supportsInterface(
) public returns
(bool)
```




### isUniqueInDAO



*Declaration:*
```solidity
function isUniqueInDAO(
) external returns
(bool isUnique)
```




## 5.Events
### PayrollPayentApprove

> when Payroll



