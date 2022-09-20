# BaseDAO





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| MAX_STEP_NUM | uint256 |
| _SENTINEL_ID | bytes32 |
| DEFAULT_FLOW_ID | bytes32 |
| _flowSteps | mapping(bytes32 => mapping(bytes32 => struct BaseDAO.StepLinkInfo)) |
| _proposalInfo | mapping(bytes32 => struct IProposalHandler.ProposalProgress) |
| _proposals | mapping(bytes32 => struct IProposalInfo.Proposal) |
| _proposalsArray | struct EnumerableSet.Bytes32Set |

## 3.Modifiers
### EnsureGovEnough



*Declaration:*
```solidity
modifier EnsureGovEnough
```



## 4.Functions

### getProposalIDByIndex



*Declaration:*
```solidity
function getProposalIDByIndex(
) external returns
(bytes32 _proposalID)
```




### generateProposalID



*Declaration:*
```solidity
function generateProposalID(
) internal returns
(bytes32 proposalID)
```




### turnBytesToAddress



*Declaration:*
```solidity
function turnBytesToAddress(
) internal returns
(address addr)
```




### init



*Declaration:*
```solidity
function init(
) public returns
(bytes callbackEvent)
```




### addDuty
Duty Related

> add user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function addDuty(
bytes32 dutyID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | user-defined dutyID, formed by keccak256


### remmoveDuty

> remove user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function remmoveDuty(
bytes32 dutyID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | user-defined dutyID, formed by keccak256


### addUser

> add user into the DAO, !!! Agent call only


*Declaration:*
```solidity
function addUser(
address account
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | target user


### removeUser

> remove user from the DAO, !!! Agent call only


*Declaration:*
```solidity
function removeUser(
address account
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | target user


### hasDuty

> identity the account have the duty or not


*Declaration:*
```solidity
function hasDuty(
address account,
bytes32 dutyID
) external returns
(bool exist)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`account` | address | the query account
|`dutyID` | bytes32 | the target duty

*Returns:*
| Arg | Description |
| --- | --- |
|`exist` | exist or not

### _hasDuty



*Declaration:*
```solidity
function _hasDuty(
) internal returns
(bool exist)
```




### getDutyOwners

> find out how many users have this duty


*Declaration:*
```solidity
function getDutyOwners(
bytes32 dutyID,
 owners
) external returns
(uint256 owners)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | target duty
|`owners` |  | amount of the duty owner


### getDutyOwnerByIndex

> get duty holder's address by index, this used to enumerate all user‘s have this duty


*Declaration:*
```solidity
function getDutyOwnerByIndex(
bytes32 dutyID,
uint256 index
) external returns
(address addr)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | bytes32 | target duty
|`index` | uint256 | index place

*Returns:*
| Arg | Description |
| --- | --- |
|`addr` | the address at that index

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
) public returns
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




### syncProposalKvDataToTopic



*Declaration:*
```solidity
function syncProposalKvDataToTopic(
) internal
```




### getFlowSteps



*Declaration:*
```solidity
function getFlowSteps(
) external returns
(struct IProposalHandler.CommitteeInfo[] infos)
```




### _isNextCommittee

> verify if the committee is the next committee

*Declaration:*
```solidity
function _isNextCommittee(
) internal returns
(bool)
```




### _appendFinishStep



*Declaration:*
```solidity
function _appendFinishStep(
) internal
```




### _execFinish



*Declaration:*
```solidity
function _execFinish(
) internal
```




### _setNextStep



*Declaration:*
```solidity
function _setNextStep(
) internal
```




### _setFlowStep



*Declaration:*
```solidity
function _setFlowStep(
) internal
```




### _decideProposal



*Declaration:*
```solidity
function _decideProposal(
) internal
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




### changeProposal



*Declaration:*
```solidity
function changeProposal(
) external
```




## 5.Events
