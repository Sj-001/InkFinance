# IDAO





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### setupFlowInfo

> add a new workflow, noramll call by agent

*Declaration:*
```solidity
function setupFlowInfo(
) external
```




### getFlowSteps

> ge flow steps

*Declaration:*
```solidity
function getFlowSteps(
) external returns
(struct IProposalHandler.CommitteeInfo[] infos)
```




### setupUCV

> setup a new UCV


*Declaration:*
```solidity
function setupUCV(
bytes32 ucvContractKey,
bytes initData
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`ucvContractKey` | bytes32 | the contract implemention mapping key in the ConfigManager
|`initData` | bytes | the initial paramters when UCV required, such as controller address, manager address, etc.


### deployByKey



*Declaration:*
```solidity
function deployByKey(
) external returns
(address deployedAddress)
```




## 5.Events
