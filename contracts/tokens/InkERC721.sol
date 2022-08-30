//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title InkERC721
/// @author InkTech <tech-support@inkfinance.xyz>
contract InkERC721 is ERC721 {
    address public creator;

    constructor(
        string memory name,
        string memory symbol,
        address addrReg
    ) ERC721(name, symbol) {

        creator = msg.sender;
    }

    function mint(address account, uint256 tokenId) public {
        _mint(account, tokenId);
    }

    function mintByCreator(address account, uint256 tokenId) public {
        require(msg.sender == creator, "not creator");
        _mint(account, tokenId);
    }
}
