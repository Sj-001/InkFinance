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



*Declaration:*
```solidity
function setupPayroll(
) external
```




### addSchedulePayee



*Declaration:*
```solidity
function addSchedulePayee(
) public
```




### signPayID



*Declaration:*
```solidity
function signPayID(
) external
```




### _checkAvailableToSign



*Declaration:*
```solidity
function _checkAvailableToSign(
) internal
```




### isPayIDSigned



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
