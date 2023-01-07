# IFund



> Each fund is an extension of UCV

## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### launch

> launch the fund (Only FundManager could execute)

*Declaration:*
```solidity
function launch(
) external
```




### startFund

> when the fund raised enough tokens, the fund admin could start fund and the fund manager
could start to using raised fund to invest
Only FunderManager could run this

*Declaration:*
```solidity
function startFund(
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

### tallyUp

> calculate the profit and transfer to the treasury
meanwhile generate share tokens for claim

*Declaration:*
```solidity
function tallyUp(
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




### getShare

> get how may fund token will get of the owner

*Declaration:*
```solidity
function getShare(
) external returns
(uint256 amount)
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




## 5.Events
