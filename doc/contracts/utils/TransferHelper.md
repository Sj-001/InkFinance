# TransferHelper


Contains helper methods for interacting with ERC20 tokens that do not consistently return true/false


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### safeTransfer
Transfers tokens from msg.sender to a recipient

> Calls transfer on token contract, errors with TF if transfer fails


*Declaration:*
```solidity
function safeTransfer(
address token,
address to,
uint256 value
) internal
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`token` | address | The contract address of the token which will be transferred
|`to` | address | The recipient of the transfer
|`value` | uint256 | The value of the transfer


## 5.Events
