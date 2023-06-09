//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./IDeploy.sol";

/* 

@dev UCV must be able to store 3 types of assets, and provide interface 
calls to deposit them and read their balance and other information.

All locally supported FTs;
All locally support NFTs, such as ERC-721 (1155?);
InkEnvelop, the minted ERC-20 pointing to metadata

UCV must be able to store deposit and payment records, 
with each record containing one metadata string that is supplied by the depositor or collector.

*/
interface IUCV is IDeploy, IERC721Receiver {
    event UCVTransfer(
        address indexed token,
        address indexed to,
        uint256 tokenType,
        uint256 tokenID,
        uint256 amount,
        uint256 transferTime
    );

    event UCVManagerDisabled(bool disabled);

    function setUCVManager(address ucvManager) external;

    function transferTo(
        address to,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 value,
        bytes memory data
    ) external returns (bool success);

    function enableUCVManager(bool enable_) external;

    /// @dev get the UCV manager address
    function getManager() external view returns (address ucvManager);

    function depositToUCV(
        string memory incomeItem,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 amount,
        string memory remark
    ) external payable;
}
