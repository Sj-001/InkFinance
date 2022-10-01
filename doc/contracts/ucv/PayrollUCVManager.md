# PayrollUCVManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### init



*Declaration:*
```solidity
function init(
) external returns
(bytes callbackEvent)
```




### setupPayroll
create a new payroll based on a proposal

> only agent could call this


*Declaration:*
```solidity
function setupPayroll(
bytes32 proposalID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | the payroll manager would load data from that proposal and create the payroll instance


### approvePayrollBatch

> after multi-signer voted, batch of payment  under a payroll should be paid

*Declaration:*
```solidity
function approvePayrollBatch(
) external
```




### claimPayroll

> claim payroll from the UCV contract

*Declaration:*
```solidity
function claimPayroll(
) external
```




### getPayrollBatch

> return payroll batches

*Declaration:*
```solidity
function getPayrollBatch(
) external returns
(struct IPayrollManager.PayrollBatchInfo[] batchs)
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
### Withdraw





