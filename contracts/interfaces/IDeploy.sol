//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IDeploy is IERC165 {
    // init for deploy and just do once time.
    function init(
        address admin,
        address config,
        bytes calldata data
    ) external returns (bytes memory callbackEvent);

    /// @dev get the type of the contract, it's constant
    ///
    /// @param typeID type of the deployed contract
    function getTypeID() external returns (bytes32 typeID);

    /// @dev 通过常量实现, 获取该合约版本, 在进行可升级合约变更时, 通过该方法判定是否可以升级.
    /// @return version the version number
    function getVersion() external returns (uint256 version);
}
