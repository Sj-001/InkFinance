# IAgent





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

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

### preExec

> pre exec mean check the execute process and see if any problems.


*Declaration:*
```solidity
function preExec(
bytes32 proposalID
) external returns
(bool success)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | target proposal

*Returns:*
| Arg | Description |
| --- | --- |
|`success` | true means works

### isExecuted



*Declaration:*
```solidity
function isExecuted(
) external returns
(bool executed)
```




### exec

> do run the proposal decision


*Declaration:*
```solidity
function exec(
bytes32 proposalID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | target proposal


### getAgentFlow

> return the flow of the agent


*Declaration:*
```solidity
function getAgentFlow(
) external returns
(bytes32 flowID)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`flowID` | the flow of the agent

### isUniqueInDAO

> this function will be used in dao, when they create the agent, they have to verify the agent has been created only once.

*Declaration:*
```solidity
function isUniqueInDAO(
) external returns
(bool isUnique)
```




## 5.Events
