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




### getFlowSteps

> ge flow steps

*Declaration:*
```solidity
function getFlowSteps(
) external returns
(struct IProposalHandler.CommitteeInfo[] infos)
```




### setupPayrollUCV

> setup a new payroll UCV


*Declaration:*
```solidity
function setupPayrollUCV(
bytes32 proposalID,
address controller
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`proposalID` | bytes32 | the ucv based on which proposal
|`controller` | address | the contract controller address


### payrollPaymentApprove
when payroll pay propal passed, agent call will call this function to approve the paymenta


*Declaration:*
```solidity
function payrollPaymentApprove(
) external
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

## 5.Events
### NewDAOCreated
event




