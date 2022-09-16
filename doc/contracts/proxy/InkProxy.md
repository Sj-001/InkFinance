# InkProxy





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

> Note this contains internal vars as well due to a bug in the docgen procedure

| Var | Type |
| --- | --- |
| _PROXY_ADMIN_ROLE | bytes32 |
| _ADDRESS_REGISTRY_SLOT | bytes32 |
| _BEACON_SLOT | bytes32 |

## 3.Modifiers
### isProxyAdmin



*Declaration:*
```solidity
modifier isProxyAdmin
```



## 4.Functions

### implementation



*Declaration:*
```solidity
function implementation(
) public returns
(address)
```




### getBeaconAddr



*Declaration:*
```solidity
function getBeaconAddr(
) public returns
(address addr)
```




### updateBeacon



*Declaration:*
```solidity
function updateBeacon(
) external isProxyAdmin
```
*Modifiers:*
| Modifier |
| --- |
| isProxyAdmin |




### init



*Declaration:*
```solidity
function init(
) public
```




### _getAddrRegistry



*Declaration:*
```solidity
function _getAddrRegistry(
) internal returns
(address)
```




### _selfInit



*Declaration:*
```solidity
function _selfInit(
) internal
```




### _getBeacon

> Returns the current beacon.

*Declaration:*
```solidity
function _getBeacon(
) internal returns
(address)
```




### _implementation

> Returns the current implementation address of the associated beacon.

*Declaration:*
```solidity
function _implementation(
) internal returns
(address)
```




### _upgradeBeaconToAndCall

> Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).

Emits a {BeaconUpgraded} event.

*Declaration:*
```solidity
function _upgradeBeaconToAndCall(
) internal
```




## 5.Events
### BeaconUpgraded

> Emitted when the beacon is upgraded.



