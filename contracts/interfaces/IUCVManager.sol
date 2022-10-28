//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVController.sol";

interface IUCVManager {
    function depositToUCV(
        string memory incomeItem,
        address token,
        uint256 amount,
        string memory remark
    ) external payable;
}
