# BaseAgent





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| _executed | bool |

## 3.Modifiers
### onlyCallFromDAO



*Declaration:*
```solidity
modifier onlyCallFromDAO
```



## 4.Functions

### initAgent



*Declaration:*
```solidity
function initAgent(
) external
```




### getDescription

> get agent description


*Declaration:*
```solidity
function getDescription(
) external returns
(string description)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`description` | description

### getAgentDAO



*Declaration:*
```solidity
function getAgentDAO(
) internal returns
(address parentDAO)
```




### getAgentFlow



*Declaration:*
```solidity
function getAgentFlow(
) external returns
(bytes32 flowID)
```




### isExecuted



*Declaration:*
```solidity
function isExecuted(
) external returns
(bool executed)
```




## 5.Events
