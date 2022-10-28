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
bytes startTime,
uint256 claimTimes,
uint256 period,
uint256 payeeInfo
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`startTime` | bytes | the payroll manager would load data from that proposal(topic) and create the payroll instance
|`claimTimes` | uint256 | the fund from which ucv
|`period` | uint256 | the fund from which ucv
|`payeeInfo` | uint256 | the fund from which ucv


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




### getSignTime
if the signer not signed, return 0


*Declaration:*
```solidity
function getSignTime(
) external returns
(uint256 signTime)
```




## 5.Events
### PayrollClaimed
when user claim payroll, this event will be emit

> once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`scheduleID` | address | :white_check_mark: | the payroll schedule id
|`claimAddress` | uint256 | :white_check_mark: | claim token's address
|`claimedBatches` | address | :white_check_mark: | how many batchs claimed
|`total` | address |  | how many token claimed
|`token` | uint256 |  | which token has been claimed
|`lastPayID` | uint256 |  | lastPayID
### NewPayrollSetup
when a new payroll has been setup, this event will be emit.




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`dao` | address | :white_check_mark: | based on which dao
|`scheduleID` | uint256 | :white_check_mark: | payroll's ID
|`payrollType` | uint256 | :white_check_mark: | 0=scheduled 1=one time 2=direct pay investor, 3=direct pay vault
|`payrollInfo` | bytes |  | payroll's title|description, etc.
|`startTime` | uint256 |  | first claimable time
|`period` | uint256 |  | period between echo claim
|`claimTimes` | uint256 |  |  how many times could claim under this payroll
### VaultDeposit

> token = address(0) means chain gas token



### PayrollSign
once the multisigner role sign, this event will pass




### PayrollPayeeAdded
once add member under a payroll, this event will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`scheduleID` | address | :white_check_mark: | passed payroll schedule id
|`payeeAddress` | uint256 | :white_check_mark: | wallet address
|`token` | address | :white_check_mark: | token address
|`oncePay` | address |  | how many token paid once
|`desc` | uint256 |  | extra infomation
