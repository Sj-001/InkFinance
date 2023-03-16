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

> after ucv manager created, call this method set ucv's manager

*Declaration:*
```solidity
function setupUCV(
) external
```




### getUCV



*Declaration:*
```solidity
function getUCV(
) external returns
(address ucv)
```




### getFlowSteps

> get flow steps

*Declaration:*
```solidity
function getFlowSteps(
) external returns
(struct IProposalHandler.CommitteeInfo[] infos)
```




### getDAODeployFactory



*Declaration:*
```solidity
function getDAODeployFactory(
) external returns
(address factoryAddress)
```




### deployByKey

> deploy

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

> create committee


*Declaration:*
```solidity
function setupCommittee(
string name,
bytes32 deployKey,
bytes dutyIDs
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`name` | string | committee's name
|`deployKey` | bytes32 | the deploy key of the committee
|`dutyIDs` | bytes | committee's dutyID


## 5.Events
### NewDAOCreated





### NewBadgeCreated





