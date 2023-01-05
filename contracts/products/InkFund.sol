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
error NotStartYet();
error FundRaiseIsOver();
error PurchaseTooMuch(uint256 left, uint256 purchase);

contract InkFund is IFundInfo, IFund, BaseUCV {

    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    uint256 private _totalRaised;

    uint256 private _principal;

    uint256 private _startRaisingDate = 0;

    uint256 private _fundStatus = 0;

    bytes32 private _fundID = bytes32(0);

    mapping(address => uint256) private _fundShare;


    NewFundInfo private _fund;



    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // init fund manager here
        console.log("InkFund init called");

        (address fundManager, bytes32 fundID, NewFundInfo memory fundInitData) = abi.decode(
            data_,
            (address, bytes32, NewFundInfo)
        );

        _init(dao_, config_, fundManager, address(0));

        _fundID = fundID;
        _fund = fundInitData;

        console.log(fundInitData.fundName);
        console.logBytes32(fundID);

        return callbackEvent;
    }


    /// @inheritdoc IFund
    function launch() external override {
        if (_startRaisingDate > 0) {
            revert FundAlreadyLaunched(_fundID);
        }
        _startRaisingDate = block.timestamp;
    }

    /// @inheritdoc IFund
    function getLaunchStatus() external view override returns (uint256 status) {
        status = _getLaunchStatus();
    }



    function _getLaunchStatus() internal view returns(uint256 status) {
        status = 0;
        if (_startRaisingDate > 0) {
            status = 1;
        }
        if (_startRaisingDate + _fund.raisedPeriod > block.timestamp) {
            status = 2;
        }
    }

    /// @inheritdoc IFund
    function purchaseShare(uint256 amount) external override {
        uint256 launchStatus = _getLaunchStatus();
        if (launchStatus == 0) {
            revert NotStartYet();
        }

        if (launchStatus == 2) {
            revert FundRaiseIsOver();
        }

        if (_totalRaised < _fund.maxRaise && _totalRaised + amount <= _fund.maxRaise) {
            
            revert PurchaseTooMuch(_fund.maxRaise - _totalRaised, amount);
        }
        
        _depositeERC20(_fund.fundToken, amount);
        _totalRaised += amount;
        _fundShare[msg.sender] += amount;

    }

    /// @inheritdoc IFund
    function getFundStatus() external view override returns (uint256 status) {
        status = _getFundStatus();
    }

    function _getFundStatus() internal view returns(uint256) {

        if (_fundStatus > 0) {
            return _fundStatus;
        }
        if (_getLaunchStatus() != 2) {
            return 0;
        }

        if (_totalRaised >= _fund.minRaise) {
            return 2;
        } else {
            return 1;
        }
    }



    /// @inheritdoc IFund
    function tallyUp() external override {

        uint256 status = _getFundStatus();
        if (status == 3) {
            _fundStatus = 9;
        }

    }

    /// @inheritdoc IFund
    function getShare(address owner)
        external
        override
        returns (uint256 amount)
    {
        // uint256 totalRaised = 0;
         
        // uint256 fundIssued = 0;

        // uint256 currentPurchased = _fundShare[proposalID][msg.sender];

        // uint256 claimableShare = currentPurchased / totalRaised * 100 * fundIssued;

    }

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
