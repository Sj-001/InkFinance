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
error NotSupport(uint256 roleType);

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

    address private _certificate;

    uint256 private _confirmedProfit = 0;

    uint256 private _voucherValue = 0;

    // when make distribution, certain amount of token should be frozened
    uint256 private _frozened = 0;

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
        emit FundStatusUpdated(_fundID, 2,  0, 0, block.timestamp);
    }


    function getLaunchTime() external view override returns(uint256 start, uint256 end) {
        return (_startRaisingDate, _startRaisingDate + _fund.raisedPeriod);
    }


    function getFundTime() external view override returns(uint256 start, uint256 end) {
        return (_startFundDate, _startFundDate + _fund.durationOfFund);
    }

    function frozen(uint256 amount) external override {
        _frozened += amount;
    }


    function getActiveAmount() external view returns (uint256 left) {
        return _getActiveAmount();
    }


    function _getActiveAmount() internal view returns (uint256 left) {
        return _totalRaised - _frozened;
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
    function purchaseShare(uint256 amount) external override payable {
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

        /*

        address to,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 value,
        bytes memory data

        */
        _depositeERC20(_fund.fundToken, amount);
        
        _totalRaised += amount;
        _fundShare[msg.sender] += amount;
        _originalShare[msg.sender] += amount;


        emit FundPurchase(getDAO(), _fundID, address(this), msg.sender, block.timestamp, amount, _originalShare[msg.sender]);

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


        uint256 fundStatus = _getFundStatus();
        if (fundStatus == 0) {
            revert StillLaunching();
        }

        //  fundStatus = 2;

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


            emit FundStart(_fundID, address(this), _startFundDate, _startFundDate + _fund.durationOfFund);

            // emit Start
            emit FundStatusUpdated(_fundID, 2, fundStatus, _fundStatus, block.timestamp);

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

            emit FundStatusUpdated(_fundID, 2, status, _fundStatus, block.timestamp);

        } else {
            revert OnlyStartedFundCoundTallyUp(status);
        }

    }

    function hasRoleSetting(uint256 roleType) external view override returns (bool has){
        if (roleType == 1) {
            has = _fund.fundManagers.length > 0;
        }

        else if (roleType == 2) {
            has = _fund.riskManagers.length > 0;
        }

        else {
            revert NotSupport(roleType);
        }

    }

    function isRoleAuthorized(uint256 roleType, address user) external view override returns (bool authroized) {
        if (roleType == 1) {
            for (uint256 i=0; i<_fund.fundManagers.length; i++) {
                if (_fund.fundManagers[i] == user) {
                    authroized = true;
                    break;
                }
            }
        } else if (roleType == 2) {

            for (uint256 i=0; i<_fund.riskManagers.length; i++) {
                if (_fund.riskManagers[i] == user) {
                    authroized = true;
                    break;
                }
            }
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
        // claimableShare = currentPurchased * 100 * 1e18 / _totalRaised;
        // claimableShare = currentPurchased;
    }


    function claimShare(address owner) external override {

        if (_fund.allowFundTokenized != 1 && _fund.allowIntermittentDistributions == 0) {
            revert NoShareCouldBeClaim();
        }

        uint256 currentPurchased = _getShare(owner);

        console.log("has share:", currentPurchased);

        // IERC20(_certificate).transferFrom(address(this), owner, currentPurchased);
        IERC20(_certificate).transfer(owner, currentPurchased);
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
        // 3 kinds of certificate
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


    function getSharePercentage(address owner) external view override returns(uint256 perc){
        
        console.log("original share:", _originalShare[owner]);
        console.log("total raised:", _totalRaised);

        
        return _originalShare[owner] * 1e18 / _totalRaised;
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


    function distribute(address owner, address token, uint256 amount) external override {
        _transferTo(owner, token, 20, 0, amount, "");
    }




    function _issueCertifcate() internal {

        _certificate = address(new InkFundCertificateToken());
        //cut the fee
        if (_fund.fixedFee == 0) {

        }

        console.log("issued token:", _certificate);
        uint256 value = _totalRaised;
        InkFundCertificateToken(_certificate).issue(_fund.tokenName, _fund.tokenName, IERC20Metadata(_fund.fundToken).decimals() ,value, address(this));
        console.log("balance:", IERC20(_certificate).balanceOf(address(this)));
        
    }


    function getCertificateInfo() external view returns(address certificate) {
        certificate = _certificate;
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
