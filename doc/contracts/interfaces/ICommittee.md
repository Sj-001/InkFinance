# ICommittee





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### getCommitteeDuties
return committee's duties



*Declaration:*
```solidity
function getCommitteeDuties(
) external returns
(bytes32[] duties)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`duties` | committee's duties

### newProposal
makeing a new proposal

> Committee doesn't create propsal, DAO is the contract creating proposal, the committee just maintain the relationship between the propsal and committee and creator.


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

### allowOperate

> verify the user has the permission to vote

*Declaration:*
```solidity
function allowOperate(
) external returns
(bool isAllow)
```




### tallyVotes

> calculate votes and find out if the proposal is passed

*Declaration:*
```solidity
function tallyVotes(
) external
```




## 5.Events
