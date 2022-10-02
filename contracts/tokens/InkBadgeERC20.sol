//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InkDeployableERC20.sol";

/// @title InkBadgeERC20
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkBadgeERC20 is InkDeployableERC20 {
    function init(
        address daoOwner,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        (string memory badegeName, uint256 amount) = abi.decode(
            data_,
            (string, uint256)
        );
        __ERC20_init(badegeName, badegeName);
        _mint(daoOwner, amount);
    }

    function getTypeID() external override returns (bytes32 typeID) {}

    function getVersion() external override returns (uint256 version) {}

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {}
}
