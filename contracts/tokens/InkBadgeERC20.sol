//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InkERC20.sol";

/// @title InkBadgeERC20
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkBadgeERC20 is InkERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 total,
        address target
    ) InkERC20(name, symbol) {
        _mint(target, total);
    }
}
