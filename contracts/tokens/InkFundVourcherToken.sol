//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InkERC20.sol";
/**
 * @title InkERC20
 * @author InkTech <tech-support@inkfinance.xyz>
 * @dev Implementation of the {IERC20} interface.
 */
contract InkFundVourcherToken is InkERC20 {
    
    function issue(string memory name_, string memory symbol_, uint256 totalSupply, address target)
        public
    {
        super.init(name_, symbol_);
        _mint(target, totalSupply);
    }


    
    function mintTo(address target, uint256 amount) public override {
        // revert NotAlowed
    }

}
