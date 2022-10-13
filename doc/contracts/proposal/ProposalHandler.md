# ProposalHandler





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| MIN_EFFECTIVE_VOTES | string |
| MIN_EFFECTIVE_VOTE_WALLETS | string |
| VOTE_FLOW | string |
| _proposals | mapping(bytes32 => struct IProposalInfo.Proposal) |

## 3.Modifiers
### onlyDAO



*Declaration:*
```solidity
modifier onlyDAO
```



## 4.Functions

### init



*Declaration:*
```solidity
function init(
) external returns
(bytes callbackEvent)
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
) public onlyDAO returns
(bytes32 proposalID)
```
*Modifiers:*
| Modifier |
| --- |
| onlyDAO |

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

### getTopicKeyProposal



*Declaration:*
```solidity
function getTopicKeyProposal(
) external returns
(bytes32 proposalID)
```




### _getTopicKeyProposal



*Declaration:*
```solidity
function _getTopicKeyProposal(
) internal returns
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




### _getProposalKvDataKeys



*Declaration:*
```solidity
function _getProposalKvDataKeys(
) internal returns
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




### flushTopicIndex



*Declaration:*
```solidity
function flushTopicIndex(
) external onlyDAO
```
*Modifiers:*
| Modifier |
| --- |
| onlyDAO |




### getProposalFlow



*Declaration:*
```solidity
function getProposalFlow(
) external returns
(bytes32 flowID)
```




### getTallyVoteRules



*Declaration:*
```solidity
function getTallyVoteRules(
) external returns
(uint256 minAgreeRatio, uint256 minEffectiveVotes, uint256 minEffectiveWallets)
```




### syncProposalKvDataToTopic



*Declaration:*
```solidity
function syncProposalKvDataToTopic(
) internal
```




### changeProposal



*Declaration:*
```solidity
function changeProposal(
) external onlyDAO
```
*Modifiers:*
| Modifier |
| --- |
| onlyDAO |




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




### _newProposal



*Declaration:*
```solidity
function _newProposal(
) internal returns
(bytes32 proposalID)
```




### _generateProposalID



*Declaration:*
```solidity
function _generateProposalID(
) internal returns
(bytes32 proposalID)
```




### decideProposal



*Declaration:*
```solidity
function decideProposal(
) external onlyDAO
```
*Modifiers:*
| Modifier |
| --- |
| onlyDAO |




### getTypeID
get the type of the contract, it's constant

> the most used type list here
DAO: keccak256(DAOTypeID) = 0xdeb63a88d4573ec3359155ef44dd570a22acdf5208f7256d196e6bb7483d1b85;
Committee: keccak256(CommitteeTypeID) = 0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;
Agent: keccak256(AgentTypeID) = 0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845;

*Declaration:*
```solidity
function getTypeID(
 typeID
) external returns
(bytes32 typeID)
```

*Args:*
| Arg | Type | Description |
| --- | --- | --- |
|`typeID` |  | type of the deployed contract



### getVersion

> get the version of the deployed contract, it's a constant, the system could
decide if we should upgrade the deployed contract according to the version.


*Declaration:*
```solidity
function getVersion(
) external returns
(uint256 version)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`version` | the version number of the deployed contract

## 5.Events
