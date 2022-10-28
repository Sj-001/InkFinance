# BaseDAO





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| EXPIRATION_KEY | string |
| MAX_STEP_NUM | uint256 |
| _SENTINEL_ID | bytes32 |
| _proposalInfo | mapping(bytes32 => struct IProposalHandler.ProposalProgress) |
| _flowSteps | mapping(bytes32 => mapping(bytes32 => struct BaseDAO.StepLinkInfo)) |
| _proposalsArray | struct EnumerableSet.Bytes32Set |
| _committees | struct IProposalHandler.CommitteeInfo[] |

## 3.Modifiers
### ensureGovEnough



*Declaration:*
```solidity
modifier ensureGovEnough
```


### onlyAgent



*Declaration:*
```solidity
modifier onlyAgent
```


### onlyCommittee



*Declaration:*
```solidity
modifier onlyCommittee
```



## 4.Functions

### getProposalIDByIndex



*Declaration:*
```solidity
function getProposalIDByIndex(
) external returns
(bytes32 _proposalID)
```




### newProposal
makeing a new proposal

> making a new proposal and generate proposal records in the DAO


*Declaration:*
```solidity
function newProposal(
struct IProposalInfo.NewProposalInfo proposal,
bool commit,
bytes data
) public returns
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

### _setupProposalFlow



*Declaration:*
```solidity
function _setupProposalFlow(
) internal
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

### getTallyVoteRules



*Declaration:*
```solidity
function getTallyVoteRules(
) external returns
(uint256 minAgreeRatio, uint256 minEffectiveVotes, uint256 minEffectiveWallets)
```




### getDAOTallyVoteRules



*Declaration:*
```solidity
function getDAOTallyVoteRules(
) external returns
(uint256 minAgreeRatio, uint256 minEffectiveVotes, uint256 minEffectiveWallets)
```




### getSupportedFlow



*Declaration:*
```solidity
function getSupportedFlow(
) external returns
(bytes32[] flows)
```




### _init



*Declaration:*
```solidity
function _init(
) public returns
(bytes callbackEvent)
```




### addDuty
Duty Related

> add user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function addDuty(
address dutyID
) external onlyAgent
```
*Modifiers:*
| Modifier |
| --- |
| onlyAgent |

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | address | user-defined dutyID, formed by keccak256


### _addDuty



*Declaration:*
```solidity
function _addDuty(
) internal
```




### getDeployedContractByKey



*Declaration:*
```solidity
function getDeployedContractByKey(
) external returns
(address deployedAddress)
```




### remmoveDuty

> remove user-defined DutyID, !!! Agent call only


*Declaration:*
```solidity
function remmoveDuty(
address dutyID
) external
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`dutyID` | address | user-defined dutyID, formed by keccak256


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




### getTopicKVdata



*Declaration:*
```solidity
function getTopicKVdata(
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
(string[] keys)
```




### getProposalTopic

> get proposal's topic, so anyone could create a new proposal with the same topic

*Declaration:*
```solidity
function getProposalTopic(
) external returns
(bytes32 topicID)
```




### decideProposal



*Declaration:*
```solidity
function decideProposal(
) external
```




### flushTopicIndex



*Declaration:*
```solidity
function flushTopicIndex(
) external
```




### getAgentIDAddr
Agent Related


*Declaration:*
```solidity
function getAgentIDAddr(
) external returns
(address agentAddr)
```




### continueExec



*Declaration:*
```solidity
function continueExec(
) external
```




### setAgentFlowID



*Declaration:*
```solidity
function setAgentFlowID(
) external
```




### getAgentFlowID



*Declaration:*
```solidity
function getAgentFlowID(
) external returns
(bytes32 flowID)
```




### _getAgentFlowID



*Declaration:*
```solidity
function _getAgentFlowID(
) internal returns
(bytes32 flowID)
```




### execTx



*Declaration:*
```solidity
function execTx(
) external
```




### getFlowSteps



*Declaration:*
```solidity
function getFlowSteps(
) external returns
(struct IProposalHandler.CommitteeInfo[] infos)
```




### setupCommittee



*Declaration:*
```solidity
function setupCommittee(
) external onlyAgent
```
*Modifiers:*
| Modifier |
| --- |
| onlyAgent |




### _setupCommittees



*Declaration:*
```solidity
function _setupCommittees(
) internal
```




### _deployCommittees



*Declaration:*
```solidity
function _deployCommittees(
) internal returns
(address committeeAddr)
```




### _setupAgents



*Declaration:*
```solidity
function _setupAgents(
) internal
```




### getProposalFlow



*Declaration:*
```solidity
function getProposalFlow(
) external returns
(bytes32 flowID)
```




### _getProposalFlow



*Declaration:*
```solidity
function _getProposalFlow(
) internal returns
(bytes32 flowID)
```




### turnBytesToAddress



*Declaration:*
```solidity
function turnBytesToAddress(
) internal returns
(address addr)
```




### getNextVoteCommitteeInfo



*Declaration:*
```solidity
function getNextVoteCommitteeInfo(
) external returns
(struct IProposalHandler.CommitteeInfo committeeInfo)
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




### _deployByFactoryKey



*Declaration:*
```solidity
function _deployByFactoryKey(
) internal returns
(address deployedAddress)
```




### deployByKey



*Declaration:*
```solidity
function deployByKey(
) external returns
(address deployedAddress)
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




### setupFlowInfo



*Declaration:*
```solidity
function setupFlowInfo(
) external onlyAgent
```
*Modifiers:*
| Modifier |
| --- |
| onlyAgent |




### setupUCV



*Declaration:*
```solidity
function setupUCV(
) external onlyAgent
```
*Modifiers:*
| Modifier |
| --- |
| onlyAgent |




### _setFlowStep



*Declaration:*
```solidity
function _setFlowStep(
) internal
```




### _addIntoCurrentCommittee



*Declaration:*
```solidity
function _addIntoCurrentCommittee(
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




### hasDAOBadges



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




### changeProposal



*Declaration:*
```solidity
function changeProposal(
) external
```




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




### _createBadge



*Declaration:*
```solidity
function _createBadge(
) internal returns
(address addr)
```




## 5.Events
