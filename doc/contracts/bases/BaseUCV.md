# BaseUCV





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers
### enableToExecute

> make sure msgSender is controller or manager, and manager has to be allow to do all the operation

*Declaration:*
```solidity
modifier enableToExecute
```


### onlyController



*Declaration:*
```solidity
modifier onlyController
```



## 4.Functions

### receive



*Declaration:*
```solidity
function receive(
) external
```




### fallback



*Declaration:*
```solidity
function fallback(
) external
```




### _init



*Declaration:*
```solidity
function _init(
) internal returns
(bytes callbackEvent)
```




### setUCVManager



*Declaration:*
```solidity
function setUCVManager(
) external
```




### transferTo



*Declaration:*
```solidity
function transferTo(
) external enableToExecute returns
(bool)
```
*Modifiers:*
| Modifier |
| --- |
| enableToExecute |




### _depositeERC20



*Declaration:*
```solidity
function _depositeERC20(
) internal
```




### _depositeERC721



*Declaration:*
```solidity
function _depositeERC721(
) internal
```




### depositToUCV



*Declaration:*
```solidity
function depositToUCV(
) external
```




### enableUCVManager



*Declaration:*
```solidity
function enableUCVManager(
) external onlyController
```
*Modifiers:*
| Modifier |
| --- |
| onlyController |




### getManager

> get the UCV manager address

*Declaration:*
```solidity
function getManager(
) external returns
(address ucvManager)
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




### onERC721Received



*Declaration:*
```solidity
function onERC721Received(
) external returns
(bytes4)
```




## 5.Events
### VaultDeposit

> token = address(0) means chain gas token



### ChainTokenDeposited





