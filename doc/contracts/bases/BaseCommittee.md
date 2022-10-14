# BaseCommittee





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| _parentDAO | address |
| _voteInfos | mapping(bytes32 => struct IVoteHandler.VoteInfo) |
| _proposalVoteDetail | mapping(bytes32 => mapping(bool => mapping(address => struct BaseCommittee.PersonVoteDetail))) |

## 3.Modifiers

## 4.Functions

### _init



*Declaration:*
```solidity
function _init(
) internal
```




### getParentDAO



*Declaration:*
```solidity
function getParentDAO(
) internal returns
(address parentDAO)
```




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

### getVoteDetailByAccount
get vote amount of a EOA



*Declaration:*
```solidity
function getVoteDetailByAccount(
struct IVoteHandler.VoteIdentity identity,
address account
) external returns
(uint256 agreeVotes, uint256 denyVotes)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`identity` | struct IVoteHandler.VoteIdentity | target proposal, include step
|`account` | address | EOA address

*Returns:*
| Arg | Description |
| --- | --- |
|`agreeVotes` | agree votes
|`denyVotes` | deny votes

### getVoteSummary

> summary information of the proposal vote


*Declaration:*
```solidity
function getVoteSummary(
struct IVoteHandler.VoteIdentity identity
) public returns
(struct IVoteHandler.VoteInfo result)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`identity` | struct IVoteHandler.VoteIdentity | which step of the proposal

*Returns:*
| Arg | Description |
| --- | --- |
|`result` | summary infomation (referal to VoteInfo struct)

### allowOperate

> verify the user has the permission to vote, and it's time to vote, etc

*Declaration:*
```solidity
function allowOperate(
) public returns
(bool allowToOperate)
```




### _hasDutyToOperate



*Declaration:*
```solidity
function _hasDutyToOperate(
) internal returns
(bool hasDutyToOperate)
```




### _vote

> by default, vote require pledge

*Declaration:*
```solidity
function _vote(
) internal
```




### getVoteDetail
get proposal vote informations



*Declaration:*
```solidity
function getVoteDetail(
struct IVoteHandler.VoteIdentity identity,
bool agreeOrDisagreeOption,
address startVoter,
uint256 pageSize
) external returns
(struct IVoteHandler.MemberVoteInfo[] voteDetails)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`identity` | struct IVoteHandler.VoteIdentity | target proposal, include step
|`agreeOrDisagreeOption` | bool | query agree vote info or disagree vote info
|`startVoter` | address | query from this address, limit query size
|`pageSize` | uint256 | limit size

*Returns:*
| Arg | Description |
| --- | --- |
|`voteDetails` | vote informations

### _checkAllowOperate



*Declaration:*
```solidity
function _checkAllowOperate(
) internal returns
(bool)
```




### _calculateVoteResults



*Declaration:*
```solidity
function _calculateVoteResults(
) internal returns
(bool _passedOrNot)
```




### _tallyVotes



*Declaration:*
```solidity
function _tallyVotes(
) internal
```




### _getProposalAccountDetail



*Declaration:*
```solidity
function _getProposalAccountDetail(
) internal returns
(uint256 agree, uint256 deny)
```




### _checkProposalStatus



*Declaration:*
```solidity
function _checkProposalStatus(
) internal returns
(bool)
```




### _checkDeadline



*Declaration:*
```solidity
function _checkDeadline(
) internal returns
(bool end)
```




### supportsInterface

> Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.

*Declaration:*
```solidity
function supportsInterface(
) public returns
(bool)
```




## 5.Events
