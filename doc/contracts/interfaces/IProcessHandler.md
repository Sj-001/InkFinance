# IProcessHandler


take controler of the vote information and vote progress


## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### getVoteExpirationTime
return the expiratin time of the proposal's step

> the expiration period was stored in the metadata, and key is Expiration
but it is just stored period, the actual date time should be add the last operatie time
for eg: every time the new proposal post or one committee stage had be decided, the operation time would be reset at that moment

*Declaration:*
```solidity
function getVoteExpirationTime(
) external returns
(uint256 expiration)
```




### getVoteCommitteeInfo
return the step of proposal


*Declaration:*
```solidity
function getVoteCommitteeInfo(
) external returns
(address committee, bytes32 step)
```




### getVotedCommittee



*Declaration:*
```solidity
function getVotedCommittee(
) external returns
(address[] committee)
```




## 5.Events
