# TreasuryIncomeManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| _auditRecords | mapping(uint256 => mapping(address => uint256)) |
| committedReport | mapping(uint256 => uint256) |

## 3.Modifiers

## 4.Functions

### init



*Declaration:*
```solidity
function init(
) external returns
(bytes callbackEvent)
```




### getInitData



*Declaration:*
```solidity
function getInitData(
) public returns
(uint256, uint256, uint256)
```




### getLatestID



*Declaration:*
```solidity
function getLatestID(
) public returns
(uint256 latestPayID)
```




### _getAuditIDs



*Declaration:*
```solidity
function _getAuditIDs(
) internal returns
(uint256[][] auditIDs)
```




### getAuditIDs



*Declaration:*
```solidity
function getAuditIDs(
) external returns
(uint256[][] auditIDs)
```




### commitReport



*Declaration:*
```solidity
function commitReport(
) public
```




### isCommittedReport



*Declaration:*
```solidity
function isCommittedReport(
) public returns
(bool committed)
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




### getTypeID



*Declaration:*
```solidity
function getTypeID(
) external returns
(bytes32 typeID)
```




### getVersion

> get the version of the deployed contract, it's a constant, the system could
decide if we should upgrade the deployed contract according to the version.


*Declaration:*
```solidity
function getVersion(
) external returns
(uint256 version)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`version` | the version number of the deployed contract

## 5.Events
### IncomeReport





