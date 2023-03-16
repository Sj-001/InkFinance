//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDeploy.sol";

interface ITreasuryIncomeManager is IDeploy {
    function getAuditIDs(uint256 startID, uint256 limit)
        external
        view
        returns (uint256[][] memory auditIDs);
}
