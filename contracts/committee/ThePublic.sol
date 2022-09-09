//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";

contract ThePublic is BaseCommittee {
    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
