//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseDAO.sol";
import "hardhat/console.sol";

contract MasterDAO is BaseDAO {
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;

    address private _theBoard;

    function init(
        address admin_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _init(admin_, config_, data_);
        return callbackEvent;
    }

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external pure override returns (uint256 version) {
        version = 3;
    }
}
