//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../bases/BaseUCV.sol";

import "../interfaces/IUCV.sol";
import "../interfaces/IFundInfo.sol";
import "../interfaces/IFund.sol";

import "../tokens/InkFundCertificateToken.sol";

import "../utils/TransferHelper.sol";
import "hardhat/console.sol";

error FundAlreadyLaunched(bytes32 fundID);
error NotStartYet();
error FundRaiseIsOver();
error PurchaseTooMuch(uint256 left, uint256 purchase);
error StillLaunching();
error FundAlreadyStartedOrFailed();
error FundRaiseFailed();
error CurrentFundStatusDonotSupportThisOperation(uint256 fundStatus);
error FundNotLaunchYet(bytes32 fundID);
error FundAlreadySucceed();
error OnlyStartedFundCoundTallyUp(uint256 currentFundStatus);
error FundInvestmentIsNotFinished(uint256 endTime, uint256 executeTime);
error NoShareCouldBeClaim();

contract InkFund is IFundInfo, IFund, BaseUCV {

    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    uint256 private _totalRaised;

    uint256 private _principal;

    uint256 private _startRaisingDate = 0;

    uint256 private _startFundDate = 0;

    uint256 private _fundStatus = 0;

    uint256 private _launchStatus = 0;

    bytes32 private _fundID = bytes32(0);

    uint256 private _fixedFeeTransferTime = 0;

    mapping(address => uint256) private _fundShare;

    mapping(address => uint256) private _originalShare;

    address private _vourcher;

    uint256 private _confirmedProfit = 0;

    uint256 private _voucherValue = 0;

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

        emit FundStatusUpdated(_fundID, 1,  0, 0, block.timestamp);

        return callbackEvent;
    }


    /// @inheritdoc IFund
    function launch() external override {
        if (_startRaisingDate > 0) {
            revert FundAlreadyLaunched(_fundID);
        }
        _launchStatus = 1;
        _startRaisingDate = block.timestamp;

        emit FundStatusUpdated(_fundID, 1,  0, _launchStatus, block.timestamp);
    }


    function getLaunchTime() external view override returns(uint256 start, uint256 end) {
        return (_startRaisingDate, _startFundDate + _fund.raisedPeriod);
    }


    /// @inheritdoc IFund
    function triggerLaunchStatus() external override {
        if (_launchStatus == 0) {
            revert FundNotLaunchYet(_fundID);
        }
        uint256 currentLaunchStatus = _getLaunchStatus();
        if (_launchStatus != currentLaunchStatus) {
            emit FundStatusUpdated(_fundID, 1, _launchStatus, currentLaunchStatus, block.timestamp);
            _launchStatus = currentLaunchStatus;
            // update fundStatus if launching is over
            if (_launchStatus == 2) {

                uint256 fundStatus = _getFundStatus();

                if (fundStatus == 1 || fundStatus == 2) {
                    emit FundStatusUpdated(_fundID, 2, 0, fundStatus, block.timestamp);
                    _fundStatus = fundStatus;
                }
            }
        }
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

        if (_startRaisingDate + _fund.raisedPeriod < block.timestamp) {
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

        if (_totalRaised > _fund.maxRaise || _totalRaised + amount > _fund.maxRaise) {
            
            revert PurchaseTooMuch(_fund.maxRaise - _totalRaised, amount);
        }
        
        _depositeERC20(_fund.fundToken, amount);
        _totalRaised += amount;
        _fundShare[msg.sender] += amount;
        _originalShare[msg.sender] += amount;

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
    function startFund() external override {
        // uint256 launchStatus = _getLaunchStatus();
        // if (launchStatus != 2) {
        //     revert StillLaunching();
        // }

        uint256 fundStatus = _getFundStatus();
        if (fundStatus == 0) {
            revert StillLaunching();
        }

        if (fundStatus == 1 || fundStatus == 3) {
            revert FundAlreadyStartedOrFailed();
        }

        if (fundStatus == 9) {
            revert FundAlreadySucceed();
        }

        if (fundStatus == 2 && _totalRaised >= _fund.minRaise) {
            _fundStatus = 3;
            _startFundDate = block.timestamp;
            

            if (_fund.allowFundTokenized == 1) {
                if (_fund.allowIntermittentDistributions == 1) {
                    // ERC3525
                } else {
                    // ERC20
                    _issueCertifcate();
                }
            } 


        } else {
            // fund raise failed
            // fundStatus = 1;
            revert FundRaiseFailed();
        }
        
    }

    /// @inheritdoc IFund
    function tallyUp() external override {


        uint256 status = _getFundStatus();
        if (status == 3) {

            if (_startRaisingDate + _fund.raisedPeriod + _fund.durationOfFund < block.timestamp) {
                revert FundInvestmentIsNotFinished(_startRaisingDate + _fund.raisedPeriod + _fund.durationOfFund, block.timestamp);
            }
            _fundStatus = 9;

            // calculate the profits and calculate per voucher's value
            _confirmedProfit = IERC20(_fund.fundToken).balanceOf(address(this));
            _voucherValue = _confirmedProfit / _totalRaised;



        } else {
            revert OnlyStartedFundCoundTallyUp(status);
        }

    }

    /// @inheritdoc IFund
    function getShare(address owner)
        external
        view 
        override
        returns (uint256 claimableShare)
    {
        claimableShare = _getShare(owner);

    }

    function getOriginalShare(address owner) external view override returns (uint256 amount) {
        amount = _originalShare[owner];
    }


    function _getShare(address owner) internal view returns(uint256 share) {
        share = _fundShare[owner];
        // if (currentPurchased == 0) {
        //     return 0;
        // }
        // // calculate based on all purchased percentage
        // // claimableShare = currentPurchased * 100 * 1e18 / _totalRaised;
        // claimableShare = currentPurchased;
    }


    function claimShare(address owner) external override {

        if (_fund.allowFundTokenized != 1) {
            revert NoShareCouldBeClaim();
        }

        uint256 currentPurchased = _getShare(owner);
        IERC20(_vourcher).transferFrom(address(this), owner, currentPurchased);
        _fundShare[owner] = 0;

    }

    /// @inheritdoc IFund
    function getRaisedInfo() external view override returns (uint256 minRaise, uint256 maxRaise, uint256 currentRaised) {
        return _getRaisedInfo();
    }

    function _getRaisedInfo() internal view returns (uint256 minRaise, uint256 maxRaise, uint256 currentRaised) {
        minRaise = _fund.minRaise;
        maxRaise = _fund.maxRaise;
        currentRaised = _totalRaised;
    }

    /// @inheritdoc IFund
    function transferFixedFeeToUCV(address treasuryUCV) external override {

        if (_fund.fixedFeeShouldGoToTreasury == 1 && _fixedFeeTransferTime ==0 && treasuryUCV != address(0)) {
            uint256 value = _fund.fixedFee * _totalRaised;
            _transferTo(treasuryUCV, _fund.fundToken, 20, 0, value, "");
            _fixedFeeTransferTime = block.timestamp;
        }
    }

    /// @inheritdoc IFund
    function claimPrincipalAndProfit(address owner) external override {
        // require enough Token to get profit
        // 3种凭证
        // 1 staking
        // 2 certificate
        // 3 
        uint256 status = _getFundStatus();
        if (status != 9) {
            revert CurrentFundStatusDonotSupportThisOperation(status);
        }

        // calculate voucher values;
        
        
        // get back vouchers

        
        uint256 vouchers = _fund.fixedFee * _totalRaised;


    }

    /// @inheritdoc IFund
    function withdrawPrincipal(address owner) external override {

        uint256 fundStatus = _getFundStatus();
        if (fundStatus != 1) {
            revert CurrentFundStatusDonotSupportThisOperation(fundStatus);
        }

        _transferTo(owner, _fund.fundToken, 20, 0, _getShare(owner), "");
        _fundShare[owner] = 0;

    }


    function _issueCertifcate() internal {

        _vourcher = address(new InkFundCertificateToken());
        //cut the fee
        if (_fund.fixedFee == 0) {

        }

        console.log("issued token:", _vourcher);
        uint256 value = _fund.fixedFee * _totalRaised;
        InkFundCertificateToken(_vourcher).issue(_fund.tokenName, _fund.tokenName, IERC20Metadata(_fund.fundToken).decimals() ,value, address(this));
        console.log("balance:", IERC20(_vourcher).balanceOf(address(this)));
        
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
