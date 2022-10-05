# FactoryManager


Factory is used to generate DAO instance


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| proxy | contract InkProxy |

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




### deploy
generate new contract storage



*Declaration:*
```solidity
function deploy(
bytes32 typeID,
bytes32 factoryKey,
bytes initData
) external returns
(address _newContract)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`typeID` | bytes32 | contract type, eg: DAO, committee, agent, etc. use typeID to verify the factoryKey is point to a proper contract address.
|`factoryKey` | bytes32 | a contract key stored in the ConfigManager which point to a contract implementation.
|`initData` | bytes | the initData of the contract

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




### getDeployedAddressCount



*Declaration:*
```solidity
function getDeployedAddressCount(
) public returns
(uint256 size)
```




## 5.Events
