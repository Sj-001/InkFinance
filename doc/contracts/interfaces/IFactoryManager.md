# IFactoryManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### deploy
generate new contract storage



*Declaration:*
```solidity
function deploy(
bytes32 typeID,
bytes32 factoryKey,
bytes initData
) external returns
(address contractAddr)
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

## 5.Events
### NewContractDeployed

> when new contract was deployed, the event will be emit.



*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`typeID` | bytes32 | :white_check_mark: | each kind of contract have different contractID
|`factoryKey` | bytes32 | :white_check_mark: | a contract key stored in the ConfigManager which point to a contract implementation.
|`newAddr` | address | :white_check_mark: | genereated new address
|`initData` | bytes |  | initial data of the contract
|`msgSender` | address |  | contract instance creator
|`timestamp` | uint256 |  | contract deployed time
