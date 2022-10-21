# IPayrollManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### setupPayroll
create a new payroll, only operator could do this



*Declaration:*
```solidity
function setupPayroll(
uint256 startTime,
uint256 claimTimes,
uint256 period,
bytes[] payeeInfo
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`startTime` | uint256 | the payroll manager would load data from that proposal(topic) and create the payroll instance
|`claimTimes` | uint256 | the fund from which ucv
|`period` | uint256 | the fund from which ucv
|`payeeInfo` | bytes[] | the fund from which ucv


### signPayID

> after multi-signer voted, how many batchs of payment under a payroll should be paid

*Declaration:*
```solidity
function signPayID(
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
(address token, uint256 amount, uint256 batches, uint256 lastPayID)
```




### getPayIDs

> util function, basically provide the method to calculate how many payIDs and their claim times listed for the signers to sign

*Declaration:*
```solidity
function getPayIDs(
) external returns
(uint256[][] payIDs)
```




### isPayIDSigned
check the pay has been signed by all the signers


*Declaration:*
```solidity
function isPayIDSigned(
) external returns
(bool isSigned)
```




## 5.Events
### PayrollClaimed
when user claim payroll, this event will be emit

> once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`scheduleID` | uint256 | :white_check_mark: | the payroll schedule id
|`claimAddress` | address | :white_check_mark: | claim token's address
|`claimedBatches` | address |  | how many batchs claimed
|`total` | uint256 |  | how many token claimed
|`token` | uint256 |  | which token has been claimed
|`lastPayID` | uint256 |  | lastPayID
### NewPayrollSetup
when a new payroll has been setup, this event will be emit.




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`dao` | address | :white_check_mark: | based on which dao
|`scheduleID` | uint256 | :white_check_mark: | payroll's ID
|`startTime` | uint256 |  | first claimable time
|`period` | uint256 |  | period between echo claim
|`claimTimes` | uint256 |  |  how many times could claim under this payroll
### ApprovePayrollBatch
once the multisigner role vote and pass the proposal(pay the batch under payroll), this event will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`topicID` | bytes32 |  | target proposalID's topicID
|`batch` | bytes32 | :white_check_mark: | the batch under the payroll
### PayrollSign





### PayrollPayeeAdded
once add member under a payroll, this event will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`scheduleID` | uint256 | :white_check_mark: | passed payroll schedule id
|`payeeAddress` | address | :white_check_mark: | wallet address
|`token` | address |  | token address
|`oncePay` | uint256 |  | how many token paid once
|`desc` | bytes |  | extra infomation
