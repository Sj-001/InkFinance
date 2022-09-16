//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

import "../interfaces/IConfigManager.sol";

/// @title InkProxy
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkProxy is Proxy {
    //////////////////// only public
    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    //////////////////// public for proxy admin
    function getBeaconAddr() public view returns (address addr) {
        return _getBeacon();
    }

    function updateBeacon(address beacon, bytes memory data)
        external
        isProxyAdmin
    {
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    //////////////////// init once
    function init(
        address config_,
        address beacon_,
        bytes memory data_
    ) public payable {
        if (_getAddrRegistry() != address(0x0)) {
            _fallback();
        } else {
            _selfInit(config_, beacon_, data_);
        }
    }

    //////////////////// setting proxy admin

    // keccak256("PROXY_ADMIN_ROLE");
    bytes32 internal constant _PROXY_ADMIN_ROLE =
        0x795eb25cb2b1be6e10a101fd5278394bdeaa6cda3086183d0982b3254e030c1a;

    modifier isProxyAdmin() {
        if (_checkProxyAdmin(msg.sender)) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev The storage slot of the Inited status.
     * This is bytes32(uint256(keccak256('proxy.AddressRegistry')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _ADDRESS_REGISTRY_SLOT =
        0x0832d3c2e76bb238cc3261a37e978f63c88fdf76f32596bb55051bdc20ec364c;

    function _getAddrRegistry() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADDRESS_REGISTRY_SLOT).value;
    }

    function _setAddrRegistry(address addrRegistry) private {
        require(
            IConfigManager(addrRegistry).supportsInterface(
                type(IConfigManager).interfaceId
            ),
            "error set addr"
        );

        StorageSlot.getAddressSlot(_ADDRESS_REGISTRY_SLOT).value = addrRegistry;
    }

    function _checkProxyAdmin(address addr) private view returns (bool) {
        // return IConfig(_getAddrRegistry()).hasRole(_PROXY_ADMIN_ROLE, addr);

        return true;
    }

    function _selfInit(
        address addrRegistry,
        address beacon,
        bytes memory data
    ) internal {
        _upgradeBeaconToAndCall(beacon, data, false);
        _setAddrRegistry(addrRegistry);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(
                IBeacon(newBeacon).implementation(),
                data
            );
        }
    }
}
