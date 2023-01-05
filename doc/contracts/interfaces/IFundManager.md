# IFundManager





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### createFund

> create a fund (UCV) for taking user's investment 
        every create fund proposal would create a independent UCV

*Declaration:*
```solidity
function createFund(
) external returns
(address contractAddr)
```




### getFund

> get the fund contract address of the fund, each fund has their own fund ucv to collect assets.

*Declaration:*
```solidity
function getFund(
) external returns
(address fundAddres)
```




### getLaunchStatus

> check the fund is launched or not


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

### launchFund

> after fund created, the fund manager could launch fund

*Declaration:*
```solidity
function launchFund(
) external
```




### startFund

> when the fund raised enough tokens, the fund admin could start fund and the fund manager
could start to using raised fund to invest

*Declaration:*
```solidity
function startFund(
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

### geFundShare

> get how many share token could claim

*Declaration:*
```solidity
function geFundShare(
) external returns
(uint256 share)
```




### claimFundShare

> claim share token

*Declaration:*
```solidity
function claimFundShare(
) external
```




### withdrawPrincipal

> withdraw principal, when launch status is over and fund status is failed

*Declaration:*
```solidity
function withdrawPrincipal(
) external
```




### claimPrincipalAndProfit

> claim principal and profit, require fund share token to prove the share

*Declaration:*
```solidity
function claimPrincipalAndProfit(
) external
```




## 5.Events
