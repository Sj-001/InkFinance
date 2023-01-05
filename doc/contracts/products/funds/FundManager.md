# FundManager





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




### createFund

> create a fund (UCV) for taking user's investment 
        every create fund proposal would create a independent UCV

*Declaration:*
```solidity
function createFund(
) external returns
(address ucvAddress)
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




### getFund

> get the fund contract address of the fund, each fund has their own fund ucv to collect assets.

*Declaration:*
```solidity
function getFund(
) external returns
(address fundAddress)
```




### getTypeID



*Declaration:*
```solidity
function getTypeID(
) external returns
(bytes32 typeID)
```




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

### _deployByFactoryKey



*Declaration:*
```solidity
function _deployByFactoryKey(
) internal returns
(address deployedAddress)
```




### turnBytesToAddress



*Declaration:*
```solidity
function turnBytesToAddress(
) internal returns
(address addr)
```




## 5.Events
