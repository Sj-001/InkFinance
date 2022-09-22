# ThePublic





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| minAgreeRatio | uint256 |
| minEffectiveVotes | uint256 |
| minEffectiveWallets | uint256 |

## 3.Modifiers

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

> Committee doesn't create propsal, DAO is the contract creating proposal, the committee just maintain the relationship between the propsal and committee and creator.


*Declaration:*
```solidity
function newProposal(
struct IProposalInfo.NewProposalInfo proposal,
bool commit,
bytes data
) external returns
(bytes32)
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

### tallyVotes

> calculate votes and find out if the proposal is passed

*Declaration:*
```solidity
function tallyVotes(
) public
```




### _calculateVoteResults



*Declaration:*
```solidity
function _calculateVoteResults(
) internal returns
(bool _passedOrNot)
```




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
