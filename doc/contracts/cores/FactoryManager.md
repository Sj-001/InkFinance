# FactoryManager


Factory is used to generate Contract instance


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| proxy | contract InkProxy |
| implement2beacon | mapping(address => struct FactoryManager.InitialiedBeacon) |
| nounce | uint256 |

## 3.Modifiers

## 4.Functions

### supportsInterface



*Declaration:*
```solidity
function supportsInterface(
) external returns
(bool)
```




### constructor



*Declaration:*
```solidity
function constructor(
) public
```




### _getPredictAddress



*Declaration:*
```solidity
function _getPredictAddress(
) internal returns
(address _calculatedAddress)
```




### _getSalt



*Declaration:*
```solidity
function _getSalt(
) internal returns
(bytes32 salt)
```




### _deploy



*Declaration:*
```solidity
function _deploy(
) internal returns
(address _newContract)
```




### deploy
generate new contract storage



*Declaration:*
```solidity
function deploy(
bool typeID,
bytes32 factoryKey,
bytes32 initData
) external returns
(address _newContract)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`typeID` | bool | contract type, eg: DAO, committee, agent, etc. use typeID to verify the factoryKey is point to a proper contract address.
|`factoryKey` | bytes32 | a contract key stored in the ConfigManager which point to a contract implementation.
|`initData` | bytes32 | the initData of the contract

*Returns:*
| Arg | Description |
| --- | --- |
|`contractAddr` | according to the factoryKey, genereated new contract address with the same kind proxy contract.

### getDeployedAddress



*Declaration:*
```solidity
function getDeployedAddress(
) public returns
(address contractAddress)
```




### clone



*Declaration:*
```solidity
function clone(
) external returns
(address _newContract)
```




### getDeployedAddressCount



*Declaration:*
```solidity
function getDeployedAddressCount(
) public returns
(uint256 size)
```




### toAsciiString



*Declaration:*
```solidity
function toAsciiString(
) public returns
(string)
```




### char



*Declaration:*
```solidity
function char(
) public returns
(bytes1 c)
```




## 5.Events
