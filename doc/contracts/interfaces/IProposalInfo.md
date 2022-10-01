# IProposalInfo


struct and events definations related to proposal


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

## 5.Events
### NewProposal
when new proposal generated, this event will be emit




### ProposalAppend
when kvData has been add to the proposal this event will be emit

> kvData if the key is the same, the value will be override



### ProposalDecide
once proposal decided, this emit will be emit




*Params:*
| Param | Type | Indexed | Description |
| --- | --- | :---: | --- |
|`dao` | address | :white_check_mark: | from which dao;
|`proposalID` | bytes32 | :white_check_mark: | proposalID
|`agree` | bool | :white_check_mark: | true=ageree, false=disagree
|`topicID` | bytes32 |  | the topic of the proposal
### ProposalTopicSynced

> once propsal decided this event will be emit



### TopicCreate





### TopicFix





