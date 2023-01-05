//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../bases/BaseUCV.sol";

import "../interfaces/IUCV.sol";
import "../interfaces/IFundInfo.sol";
import "../interfaces/IFund.sol";

import "../utils/TransferHelper.sol";
import "hardhat/console.sol";

error FundAlreadyLaunched(bytes32 fundID);

contract InkFund is IFundInfo, IFund, BaseUCV {
    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    uint256 private _totalRaised;

    uint256 private _principal;

    FundInfo private _fund;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // init fund manager here
        console.log("InkFund init called");

        (address fundManager, NewFundInfo memory fundInitData) = abi.decode(
            data_,
            (address, NewFundInfo)
        );

        _init(dao_, config_, fundManager, address(0));

        // issue token
        return callbackEvent;
    }

    mapping(address => uint256) private _fundShare;

    /// @inheritdoc IFund
    function launch() external override {
        if (_fund.startRaisingDate > 0) {
            revert FundAlreadyLaunched(_fund.fundID);
        }

        _fund.startRaisingDate = block.timestamp;
    }

    /// @inheritdoc IFund
    function getLaunchStatus() external view override returns (uint256 status) {
        status = 0;
        if (_fund.startRaisingDate > 0) {
            status = 1;
        }
        if (_fund.startRaisingDate + _fund.raisingPeriod > block.timestamp) {
            status = 2;
        }
    }

    /// @inheritdoc IFund
    function purchaseShare(uint256 amount) external override {}

    /// @inheritdoc IFund
    function getFundStatus() external override returns (uint256 status) {}

    /// @inheritdoc IFund
    function tallyUp() external override {}

    /// @inheritdoc IFund
    function getShare(address owner)
        external
        override
        returns (uint256 amount)
    {}

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IUCV).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
