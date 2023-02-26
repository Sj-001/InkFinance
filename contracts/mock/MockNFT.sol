//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

/// @notice mock NFT Contract
contract MockNFT is ERC721Enumerable, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => EnumerableSet.UintSet) private ownedNFTs;

    uint256 private _totalMinted = 0;

    constructor() ERC721("MockNFT", "MNT") {}

    function mint(address owner, uint256 quantity) external {
        _doMint(owner, quantity);
    }

    function _doMint(address purchaseUser, uint256 quantity)
        internal
        returns (uint256[] memory tokenIDs)
    {
        EnumerableSet.UintSet storage nftSet = ownedNFTs[purchaseUser];

        uint256 currentTokenID = _totalMinted;
        for (uint256 i = 0; i < quantity; i++) {
            currentTokenID = currentTokenID + 1;
            nftSet.add(currentTokenID);
            _safeMint(purchaseUser, currentTokenID);
        }

        _totalMinted = currentTokenID;
    }

    function listMyNFT(address walletAddress)
        external
        view
        returns (uint256[] memory tokens)
    {
        EnumerableSet.UintSet storage nftSets = ownedNFTs[walletAddress];
        tokens = nftSets.values();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
        EnumerableSet.UintSet storage fromSets = ownedNFTs[from];
        fromSets.remove(tokenId);

        super.transferFrom(from, to, tokenId);

        EnumerableSet.UintSet storage nftSets = ownedNFTs[to];
        nftSets.add(tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721) {
        EnumerableSet.UintSet storage fromSets = ownedNFTs[from];
        fromSets.remove(tokenId);
        super.safeTransferFrom(from, to, tokenId, data);
        EnumerableSet.UintSet storage nftSets = ownedNFTs[to];
        nftSets.add(tokenId);
    }
}
