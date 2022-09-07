//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title InkERC20
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkERC20 is ERC20 {
    address public creator;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        creator = msg.sender;
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function mintByCreator(address account, uint256 amount) public {
        require(msg.sender == creator, "not creator");
        _mint(account, amount);
    }
}
