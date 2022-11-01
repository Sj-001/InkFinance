# PayrollUCVManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| FIRST_PAY_ID | uint256 |

## 3.Modifiers

## 4.Functions

### getPayIDs

> calculate pay id for schedule, as for the unlimited claim times, use limit to calculate possible time


*Declaration:*
```solidity
function getPayIDs(
) external returns
(uint256[][] payIDs)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`payIDs` | payIDs[0][0] = payID(1,2,3,4....), payIDs[0][1] = actual claimable time

### getLatestPayID

> according to the start timestamp, calculated the lastest payID, which could be sign and claimed

*Declaration:*
```solidity
function getLatestPayID(
) public returns
(uint256 latestPayID)
```




### init



*Declaration:*
```solidity
function init(
) external returns
(bytes callbackEvent)
```




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


### getPayInfo



*Declaration:*
```solidity
function getPayInfo(
) external returns
(struct IPayrollManager.PaymentInfo info)
```




### addSchedulePayee



*Declaration:*
```solidity
function addSchedulePayee(
) public
```




### _validPayeeType



*Declaration:*
```solidity
function _validPayeeType(
) internal
```




### signPayID

> after multi-signer voted, how many batchs of payment under a payroll should be paid

*Declaration:*
```solidity
function signPayID(
) external
```




### _checkDirectPay



*Declaration:*
```solidity
function _checkDirectPay(
) internal
```




### _checkAvailableToSign



*Declaration:*
```solidity
function _checkAvailableToSign(
) internal
```




### isPayIDSigned
check the pay has been signed by all the signers


*Declaration:*
```solidity
function isPayIDSigned(
) external returns
(bool isSigned)
```




### _isPayIDSigned



*Declaration:*
```solidity
function _isPayIDSigned(
) internal returns
(bool allSignerSigned)
```




### _transferSchedulePay



*Declaration:*
```solidity
function _transferSchedulePay(
) internal
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




### _getClaimableAmount



*Declaration:*
```solidity
function _getClaimableAmount(
) internal returns
(address token, uint256 amount, uint256 batches, uint256 lastPayID)
```




### getSignTime
if the signer not signed, return 0


*Declaration:*
```solidity
function getSignTime(
) external returns
(uint256 signTime)
```




### depositToUCV



*Declaration:*
```solidity
function depositToUCV(
) external
```




### _send



*Declaration:*
```solidity
function _send(
) public
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
