//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVController.sol";

interface IPayrollManager {

    function setupPayroll(bytes32 proposalID) external;
    
}
