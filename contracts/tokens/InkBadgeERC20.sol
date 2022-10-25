//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InkERC20.sol";

import "../interfaces/IDeploy.sol";

/// @title InkBadgeERC20
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkBadgeERC20 is InkERC20, IDeploy {
    

    function init(
        address admin,
        address config,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {
        (string memory name, address account, uint256 amount) = abi.decode(data, (string, address, uint256));
        super.init(name, name);
        _mint(account, amount);
    }

   function getTypeID() external override returns (bytes32 typeID) {

    }


    function getVersion() external override returns (uint256 version) {

    }


    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IDeploy).interfaceId;
    }

}
