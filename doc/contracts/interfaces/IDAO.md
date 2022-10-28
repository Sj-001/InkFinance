# IDAO





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### hasDAOBadges

> check the account has badges or not

*Declaration:*
```solidity
function hasDAOBadges(
) external returns
(bool hasBadges)
```




### allowToVote
verify if the account could vote

> if dao dao require the badeges to vote or enought pledged tokens

*Declaration:*
```solidity
function allowToVote(
) external returns
(bool isAllow)
```




### setupFlowInfo

> add a new workflow, noramll call by agent

*Declaration:*
```solidity
function setupFlowInfo(
) external
```




### setupUCV



*Declaration:*
```solidity
function setupUCV(
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




### deployByKey



*Declaration:*
```solidity
function deployByKey(
) external returns
(address deployedAddress)
```




### getDAOCommittees
return all commitees and it's dutyIDs



*Declaration:*
```solidity
function getDAOCommittees(
) external returns
(struct IDAO.DAOCommitteeWithDuty[] committeeDuties)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`committeeDuties` | return the committee's dutyID as array

### setupCommittee



*Declaration:*
```solidity
function setupCommittee(
) external
```




## 5.Events
### NewDAOCreated
event




### NewBadgeCreated





