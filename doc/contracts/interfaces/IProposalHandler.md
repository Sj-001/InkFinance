# IProposalHandler


inteface which defined how to deal with the vote process


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### newProposal



*Declaration:*
```solidity
function newProposal(
) external returns
(bytes32 proposalID)
```




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
(bytes32[] keys)
```




### flushTopicIndex



*Declaration:*
```solidity
function flushTopicIndex(
) external
```




## 5.Events
