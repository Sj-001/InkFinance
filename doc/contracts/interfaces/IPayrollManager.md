# IPayrollManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### setupPayroll
create a new payroll based on a proposal

> only agent could call this


*Declaration:*
```solidity
function setupPayroll(
bytes32 topicID,
address ucv
) external
```

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

> calculate how many time and how many token the user can claim under a proposal

*Declaration:*
```solidity
function getClaimableAmount(
) external returns
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




## 5.Events
### PayrollClaimed
when user claim payroll, this event will be emit

> once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`proposalID` | bytes32 | :white_check_mark: | the payroll under which proposal
|`claimAddress` | address | :white_check_mark: | claim token's address
|`claimedBatchs` | uint256 | :white_check_mark: | how many batchs claimed
|`total` | uint256 |  | how many token claimed
|`token` | address |  | which token has been claimed
### NewPayrollSetup
when a new payroll has been setup, this event will be emit.




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`proposalID` | bytes32 | :white_check_mark: | based on which proposal
|`claimPeriod` | uint256 |  | claim period between each batch
|`availableTimes` | uint256 |  | how many times could claim under this payroll
|`firstClaimTime` | uint256 |  | first claimable time
### ApprovePayrollBatch
once the multisigner role vote and pass the proposal(pay the batch under payroll), this event will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`proposalID` | bytes32 | :white_check_mark: | target proposalID
|`batch` | uint256 | :white_check_mark: | the batch under the payroll
### PayrollMemberAdded
once add member under a payroll, this event will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`proposalID` | bytes32 | :white_check_mark: | passed payroll proposalID
|`memberAddr` | address | :white_check_mark: | wallet address
|`token` | address |  | token address
|`oncePay` | uint256 |  | how many token paid once
|`desc` | bytes |  | extra infomation
