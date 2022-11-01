# PayrollUCV





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




### init



*Declaration:*
```solidity
function init(
) external returns
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




### getTypeID
get the type of the contract, it's constant

> the most used type list here
DAO: keccak256(DAOTypeID) = 0xdeb63a88d4573ec3359155ef44dd570a22acdf5208f7256d196e6bb7483d1b85;
Committee: keccak256(CommitteeTypeID) = 0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;
Agent: keccak256(AgentTypeID) = 0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845;

*Declaration:*
```solidity
function getTypeID(
 typeID
) external returns
(bytes32 typeID)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`typeID` |  | type of the deployed contract



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




## 5.Events
### ChainTokenDeposited





