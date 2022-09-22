# IProposalHandler


inteface which defined how to deal with the vote process


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### newProposal
makeing a new proposal

> making a new proposal and generate proposal records in the DAO


*Declaration:*
```solidity
function newProposal(
struct IProposalInfo.NewProposalInfo proposal,
bool commit,
bytes data
) external returns
(bytes32 proposalID)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposal` | struct IProposalInfo.NewProposalInfo | content of the proposal
|`commit` | bool | if proposal content is huge, the frontend could set commit as False, and submit multiple times
|`data` | bytes | support data, decide by case

*Returns:*
| Arg | Description |
| --- | --- |
|`proposalID` | generated proposal id

### changeProposal



*Declaration:*
```solidity
function changeProposal(
) external
```




### decideProposal



*Declaration:*
```solidity
function decideProposal(
) external
```




### getTopicKeyProposal



*Declaration:*
```solidity
function getTopicKeyProposal(
) external returns
(bytes32 proposalID)
```




### getTopicMetadata



*Declaration:*
```solidity
function getTopicMetadata(
) external returns
(bytes32 typeID, bytes data)
```




### getTopicInfo



*Declaration:*
```solidity
function getTopicInfo(
) external returns
(struct IProposalInfo.Topic topic)
```




### getProposalSummary



*Declaration:*
```solidity
function getProposalSummary(
) external returns
(struct IProposalInfo.ProposalSummary proposal)
```




### getProposalMetadata



*Declaration:*
```solidity
function getProposalMetadata(
) external returns
(bytes32 typeID, bytes data)
```




### getProposalKvData



*Declaration:*
```solidity
function getProposalKvData(
) external returns
(bytes32 typeID, bytes data)
```




### getProposalKvDataKeys



*Declaration:*
```solidity
function getProposalKvDataKeys(
) external returns
(string[] keys)
```




### flushTopicIndex



*Declaration:*
```solidity
function flushTopicIndex(
) external
```




## 5.Events
