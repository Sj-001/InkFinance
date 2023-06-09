# InkFund





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### init



*Declaration:*
```solidity
function init(
) external returns
(bytes callbackEvent)
```




### launch

> launch the fund (Only FundManager could execute)

*Declaration:*
```solidity
function launch(
) external
```




### getLaunchTime



*Declaration:*
```solidity
function getLaunchTime(
) external returns
(uint256 start, uint256 end)
```




### triggerLaunchStatus

> manually update launch status

*Declaration:*
```solidity
function triggerLaunchStatus(
) external
```




### getLaunchStatus

> get launch status


*Declaration:*
```solidity
function getLaunchStatus(
) external returns
(uint256 status)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`status` | 0=not launched yet 1=launching 2=launch finished(time is over)

### _getLaunchStatus



*Declaration:*
```solidity
function _getLaunchStatus(
) internal returns
(uint256 status)
```




### purchaseShare

> purchase the fund share
have to meet requirement
1. still launching
2. raised fund + amount less than max raise

*Declaration:*
```solidity
function purchaseShare(
) external
```




### getFundStatus

> get fund's status


*Declaration:*
```solidity
function getFundStatus(
) external returns
(uint256 status)
```


*Returns:*
| Arg | Description |
| --- | --- |
|`status` | 
0=not start yet(need to start fund) 
1=failed(launch status is finished and raised fund not reach min raise tokens) 
2=could start
3=started
9=finished(could claim the principal & profit of investment)

### _getFundStatus



*Declaration:*
```solidity
function _getFundStatus(
) internal returns
(uint256)
```




### startFund

> when the fund raised enough tokens, the fund admin could start fund and the fund manager
could start to using raised fund to invest
meanwhile generate share tokens for claim
Only FunderManager could run this

*Declaration:*
```solidity
function startFund(
) external
```




### tallyUp

> calculate the profit and transfer to the treasury

*Declaration:*
```solidity
function tallyUp(
) external
```




### getShare

> get how may fund token will get of the owner

*Declaration:*
```solidity
function getShare(
) external returns
(uint256 claimableShare)
```




### _getShare



*Declaration:*
```solidity
function _getShare(
) internal returns
(uint256 share)
```




### claimShare



*Declaration:*
```solidity
function claimShare(
) external
```




### getRaisedInfo

> get the fund raised progress

*Declaration:*
```solidity
function getRaisedInfo(
) external returns
(uint256 minRaise, uint256 maxRaise, uint256 currentRaised)
```




### _getRaisedInfo



*Declaration:*
```solidity
function _getRaisedInfo(
) internal returns
(uint256 minRaise, uint256 maxRaise, uint256 currentRaised)
```




### transferFixedFeeToUCV

> fund manager ask to pay for the fixed fee

*Declaration:*
```solidity
function transferFixedFeeToUCV(
) external
```




### claimPrincipalAndProfit

> after Admin click tallyUp the fund and the profit is ready,
then user could claim the principal and profit

*Declaration:*
```solidity
function claimPrincipalAndProfit(
) external
```




### withdrawPrincipal

> when launching is finished and can't raise enough token,
the user could withdraw their principal

*Declaration:*
```solidity
function withdrawPrincipal(
) external
```




### _issueVoucher



*Declaration:*
```solidity
function _issueVoucher(
) internal
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




### onERC721Received



*Declaration:*
```solidity
function onERC721Received(
) external returns
(bytes4)
```




## 5.Events
