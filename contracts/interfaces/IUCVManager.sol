//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVController.sol";

interface IUCVManager {
    /// @notice set which ucv to manager
    function setUCV(address ucv) external;
}
