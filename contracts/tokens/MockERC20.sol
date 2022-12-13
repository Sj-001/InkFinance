//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";


/**
 * @title MockERC20
 * @author InkTech <tech-support@inkfinance.xyz>
 * @dev Implementation of the {IERC20} interface.
 */
contract MockERC20 is ERC20 {


    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}


    function mintTo(address target, uint256 amount) public {
        _mint(target, amount);
    }
}
