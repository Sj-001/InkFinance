# DefaultAgent





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| FLOW_ID | bytes32 |

## 3.Modifiers

## 4.Functions

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




## 5.Events
