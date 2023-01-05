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
|`status` | 0=not launched yet 1=launched 2=launch finished(time is over)

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
|`status` | 0=not start yet(need to start fund) 1=failed(launch status is finished and raised fund not reach min raise tokens) 2=started 3=finished(could claim the principal & profit of investment)

### tallyUp

> calculate the profit and transfer to the treasury
meanwhile generate share tokens for claim

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
(uint256 amount)
```




## 5.Events
