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

> todo todo DAO only


*Declaration:*
```solidity
function setupPayroll(
bytes32 topicID,
address ucv
) external daoOnly
```
*Modifiers:*
| Modifier |
| --- |
| daoOnly |

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`topicID` | bytes32 | the payroll manager would load data from that proposal(topic) and create the payroll instance
|`ucv` | address | the fund from which ucv


### approvePayrollBatch

> after multi-signer voted, how many batchs of payment under a payroll should be paid

*Declaration:*
```solidity
function approvePayrollBatch(
) external
```




### claimPayroll

> claim payroll from the UCV contract and everytime claimed amount is approved batch(not claimed before) multiply once time payment

*Declaration:*
```solidity
function claimPayroll(
) external
```




### getClaimableAmount

> calculate how many time and how many token the user can claim under a proposal's topicID

*Declaration:*
```solidity
function getClaimableAmount(
) external returns
(uint256 leftTimes, uint256 leftAmount, address token)
```




### _getClaimableAmount



*Declaration:*
```solidity
function _getClaimableAmount(
) internal returns
(uint256 leftTimes, uint256 leftAmount, address token)
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





