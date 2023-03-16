# InkBeacon





## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### constructor

> Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
beacon.

*Declaration:*
```solidity
function constructor(
) public
```




### implementation

> Returns the current implementation address.

*Declaration:*
```solidity
function implementation(
) public returns
(address)
```




### upgradeTo

> Upgrades the beacon to a new implementation.

Emits an {Upgraded} event.

Requirements:

- msg.sender must be the owner of the contract.
- `newImplementation` must be a contract.

*Declaration:*
```solidity
function upgradeTo(
) public
```




## 5.Events
### Upgraded

> Emitted when the implementation returned by the beacon is changed.



