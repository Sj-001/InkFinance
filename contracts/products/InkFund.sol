//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../bases/BaseUCV.sol";

import "../interfaces/IUCV.sol";
import "../interfaces/IFundInfo.sol";
import "../interfaces/IFund.sol";
import "../interfaces/IFundManager.sol";

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
error OnlyStartedFundCouldTallyUp(uint256 currentFundStatus);
error FundInvestmentIsNotFinished(uint256 endTime, uint256 executeTime);
error NoShareCouldBeClaim();
error NotSupport(uint256 roleType);
error CertificatedClaimed();

contract InkFund is IFundInfo, IFund, BaseUCV {
    event FundManagementFeeDistribute(
        bytes32 fundID,
        address[] member,
        uint256[] fee,
        bytes data
    );

    using EnumerableSet for EnumerableSet.UintSet;

    using Address for address;

    /// how many token raised;
    uint256 private _totalRaised;

    uint256 private _startRaisingDate = 0;

    /// raised principal - tax
    uint256 private _fundAvailablePrincipal = 0;

    uint256 private _startFundDate = 0;

    uint256 private _fundStatus = 0;

    uint256 private _launchStatus = 0;

    bytes32 private _fundID = bytes32(0);

    uint256 private _fixedFeeTransferTime = 0;

    uint256 private _performanceFeeTransferTime = 0;

    // mapping(address => uint256) private _fundShare;

    mapping(address => uint256) private _originalInvested;

    mapping(address => uint256) private _investmentClaimed;

    mapping(address => uint256) private _certificateClaimed;

    address private _certificate;

    uint256 private _confirmedProfit = 0;

    uint256 private _voucherValue = 0;

    bool private _isLiqudating = false;

    uint256 private _serviceFee = 0;

    /// @dev after dissolved, _investmentProfit represent profits(all distributions + current principal - raised - fixed management fee)
    uint256 private _investmentProfit = 0;

    // when make distribution, certain amount of token should be frozened
    uint256 private _frozened = 0;

    NewFundInfo private _fund;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // init fund manager here
        (
            address fundManager,
            bytes32 fundID,
            NewFundInfo memory fundInitData
        ) = abi.decode(data_, (address, bytes32, NewFundInfo));

        _init(dao_, config_, fundManager, address(0));

        _fundID = fundID;
        _fund = fundInitData;

        emit FundStatusUpdated(_fundID, 1, 0, 0, block.timestamp);
        return callbackEvent;
    }

    /// @inheritdoc IFund
    function launch() external override enableToExecute {
        if (_startRaisingDate > 0) {
            revert FundAlreadyLaunched(_fundID);
        }
        _launchStatus = 1;
        _startRaisingDate = block.timestamp;

        emit LaunchStart(
            _fundID,
            address(this),
            _startRaisingDate,
            _startRaisingDate + _fund.raisedPeriod
        );
        // emit FundStatusUpdated(_fundID, 1,  0, _launchStatus, block.timestamp);
        emit FundStatusUpdated(_fundID, 2, 0, 0, block.timestamp);
    }

    function getLaunchTime()
        external
        view
        override
        returns (uint256 start, uint256 end)
    {
        return (_startRaisingDate, _startRaisingDate + _fund.raisedPeriod);
    }

    function getFundTime()
        external
        view
        override
        returns (uint256 start, uint256 end)
    {
        return (_startFundDate, _startFundDate + _fund.durationOfFund);
    }

    function frozen(uint256 amount) external override enableToExecute {
        _frozened += amount;
    }

    function isLiquidate() external view override returns (bool) {
        return _isLiqudating;
    }

    /// @dev profits = all distributions + current principal - raised - fixed management fee
    function _calculateInvestmentProfit()
        internal
        view
        returns (uint256 profit)
    {
        uint256 income = IFundManager(_getManager()).getFundDistributionAmount(
            _fundID
        ) + _getAvailablePrincipal();

        uint256 spend = _totalRaised + calculateFee(_fund.fixedFee);
        if (income > spend) {
            profit = income - spend;
        } else {
            profit = 0;
        }
    }

    function getAvailablePrincipal()
        external
        view
        override
        returns (uint256 left)
    {
        return _getAvailablePrincipal();
    }

    function _getAvailablePrincipal() internal view returns (uint256 left) {
        // return _fundAvailablePrincipal - _frozened;

        if (_fund.fundToken == address(0)) {
            return address(this).balance - _frozened;
        } else {
            return IERC20(_fund.fundToken).balanceOf(address(this)) - _frozened;
        }
        // return _fundAvailablePrincipal - _frozened;
    }

    /// @inheritdoc IFund
    function triggerLaunchStatus() external override enableToExecute {
        if (_launchStatus == 0) {
            revert FundNotLaunchYet(_fundID);
        }

        uint256 currentLaunchStatus = _getLaunchStatus();
        if (_launchStatus != currentLaunchStatus) {
            emit FundStatusUpdated(
                _fundID,
                1,
                _launchStatus,
                currentLaunchStatus,
                block.timestamp
            );
            _launchStatus = currentLaunchStatus;
            // update fundStatus if launching is over
            if (_launchStatus == 2) {
                uint256 fundStatus = _getFundStatus();

                if (fundStatus == 1 || fundStatus == 2) {
                    emit FundStatusUpdated(
                        _fundID,
                        2,
                        0,
                        fundStatus,
                        block.timestamp
                    );
                    _fundStatus = fundStatus;
                    if (fundStatus == 1) {
                        _confirmedProfit = _getAvailablePrincipal();
                    }
                }
            }
        }
    }

    /// @inheritdoc IFund
    function getLaunchStatus() external view override returns (uint256 status) {
        status = _getLaunchStatus();
    }

    function _getLaunchStatus() internal view returns (uint256 status) {
        status = 0;
        if (_startRaisingDate > 0) {
            status = 1;
        }

        if (_startRaisingDate + _fund.raisedPeriod < block.timestamp) {
            status = 2;
        }
    }

    /// @inheritdoc IFund
    function purchaseShare(uint256 amount) external payable override {
        uint256 launchStatus = _getLaunchStatus();

        if (launchStatus == 0) {
            revert NotStartYet();
        }

        if (launchStatus == 2) {
            revert FundRaiseIsOver();
        }

        if (
            _totalRaised > _fund.maxRaise ||
            _totalRaised + amount > _fund.maxRaise
        ) {
            revert PurchaseTooMuch(_fund.maxRaise - _totalRaised, amount);
        }

        _depositeERC20(_fund.fundToken, amount);

        _totalRaised += amount;

        // _fundShare[msg.sender] += amount;
        _originalInvested[msg.sender] += amount;

        emit FundPurchase(
            getDAO(),
            _fundID,
            address(this),
            msg.sender,
            block.timestamp,
            amount,
            _originalInvested[msg.sender]
        );
    }

    function getClaimableCertificate(address investor)
        external
        view
        override
        returns (uint256 amount)
    {
        return _getClaimableCertificate(investor);
    }

    function _getClaimableCertificate(address investor)
        internal
        view
        returns (uint256 amount)
    {
        if (_certificate != address(0) && _certificateClaimed[investor] == 0) {
            amount = _originalInvested[investor];
        }
    }

    function getClaimableInvestment(address investor)
        external
        view
        override
        returns (uint256 amount)
    {
        return _getClaimableInvestment(investor);
    }

    function _getClaimableInvestment(address investor)
        internal
        view
        returns (uint256 amount)
    {
        uint256 status = _getFundStatus();
        if (status != 1 && status != 9) {
            amount = 0;
        }

        if (_certificate == address(0)) {
            if (_investmentClaimed[investor] == 0) {
                amount =
                    (_originalInvested[investor] * _confirmedProfit) /
                    _totalRaised;
            }
        } else {
            uint256 userOwned = IERC20(_certificate).balanceOf(investor);
            amount = (userOwned * _confirmedProfit) / _totalRaised;
        }
    }

    function claimCertificate(address investor) external override {
        if (_certificateClaimed[investor] > 0) {
            // revert CertificatedClaimed();
            return;
        }
        uint256 certificates = _getClaimableCertificate(investor);
        _certificateClaimed[investor] = certificates;
        _transferTo(investor, _certificate, 20, 0, certificates, "");
    }

    function claimInvestment(address investor) external override {
        uint256 status = _getFundStatus();
        require(status == 1 || status == 9, "Current fund status is wrong");

        if (_certificate == address(0)) {
            // claim directly
            if (_investmentClaimed[investor] == 0) {
                // claim profit and principal
                uint256 profitAndPrincipal = _getClaimableInvestment(investor);

                if (profitAndPrincipal > 0) {
                    _transferTo(
                        investor,
                        _fund.fundToken,
                        20,
                        0,
                        profitAndPrincipal,
                        ""
                    );
                    _investmentClaimed[investor] = profitAndPrincipal;
                }
            }
        } else {
            // claim based on tokens
            // authorized first
            // calculate based on how many token they have

            uint256 userOwned = IERC20(_certificate).balanceOf(investor);
            IERC20(_certificate).transferFrom(
                investor,
                address(this),
                userOwned
            );
            uint256 claimableAmount = (userOwned * _confirmedProfit) /
                _totalRaised;
            _transferTo(investor, _fund.fundToken, 20, 0, claimableAmount, "");
        }

        // } else {
        //     revert CurrentFundStatusDonotSupportThisOperation(status);
        // }
    }

    function assignFundServiceFee(
        address[] memory members,
        uint256[] memory fee,
        bytes memory data
    ) external override enableToExecute {
        // calculate fee == serviceFee
        require(members.length == fee.length, "assign data error");
        uint256 totalAssign = 0;
        for (uint256 i = 0; i < fee.length; i++) {
            totalAssign += fee[i];
        }

        require(totalAssign == _serviceFee, "assign fee error");
        for (uint256 i = 0; i < members.length; i++) {
            _transferTo(members[i], _fund.fundToken, 20, 0, fee[i], "");
        }

        _frozened -= _serviceFee;
        _serviceFee = 0;

        emit FundManagementFeeDistribute(_fundID, members, fee, data);
    }

    /// @inheritdoc IFund
    function getFundStatus() external view override returns (uint256 status) {
        status = _getFundStatus();
    }

    function _getFundStatus() internal view returns (uint256) {
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
    function startFund(address treasury) external override {
        uint256 fundStatus = _getFundStatus();
        if (fundStatus == 0) {
            // revert StillLaunching();
            require(false, "still launching");
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

            //

            takeFixedFee(treasury);

            emit FundStart(
                _fundID,
                address(this),
                _startFundDate,
                _startFundDate + _fund.durationOfFund
            );

            // emit Start
            emit FundStatusUpdated(
                _fundID,
                2,
                fundStatus,
                _fundStatus,
                block.timestamp
            );
        } else {
            // fund raise failed
            // fundStatus = 1;
            revert FundRaiseFailed();
        }
    }

    /// @inheritdoc IFund
    function dissolve(address ucv) external override {

        uint256 status = _getFundStatus();
        require(status == 3, "Only started fund could tally up");
        require(
            block.timestamp >= _startFundDate + _fund.durationOfFund,
            "Need to wait until investment period finished"
        );
        _fundStatus = 9;
        emit FundStatusUpdated(
            _fundID,
            2,
            status,
            _fundStatus,
            block.timestamp
        );
        // how much left
        _confirmedProfit = _getAvailablePrincipal();
        // how much earned duration the investment period
        _investmentProfit = _calculateInvestmentProfit();

        if (_investmentProfit > 0) {
            _takePerformanceFee(ucv);
        }
    }

    function hasRoleSetting(uint256 roleType)
        external
        view
        override
        returns (bool has)
    {
        if (roleType == 1) {
            has = _fund.fundManagers.length > 0;
        } else if (roleType == 2) {
            has = _fund.riskManagers.length > 0;
        } else {
            // revert NotSupport(roleType);

            has = false;
        }
    }

    function isRoleAuthorized(uint256 roleType, address user)
        external
        view
        override
        returns (bool authroized)
    {
        if (roleType == 1) {
            for (uint256 i = 0; i < _fund.fundManagers.length; i++) {
                if (_fund.fundManagers[i] == user) {
                    authroized = true;
                    break;
                }
            }
        } else if (roleType == 2) {
            for (uint256 i = 0; i < _fund.riskManagers.length; i++) {
                if (_fund.riskManagers[i] == user) {
                    authroized = true;
                    break;
                }
            }
        }
    }

    function getOriginalInvested(address owner)
        external
        view
        override
        returns (uint256 amount)
    {
        amount = _originalInvested[owner];
    }

    /// @inheritdoc IFund
    function getRaisedInfo()
        external
        view
        override
        returns (
            uint256 minRaise,
            uint256 maxRaise,
            uint256 currentRaised
        )
    {
        return _getRaisedInfo();
    }

    function _getRaisedInfo()
        internal
        view
        returns (
            uint256 minRaise,
            uint256 maxRaise,
            uint256 currentRaised
        )
    {
        minRaise = _fund.minRaise;
        maxRaise = _fund.maxRaise;
        currentRaised = _totalRaised;
    }

    function _takeFeeToTreasury(
        address treasuryUCV,
        uint256 fee,
        uint256 percentageToTreasury,
        bytes memory comment
    ) internal {

        console.log("fee is :", fee);
        console.log("percentage to treasury :", percentageToTreasury);

        if (percentageToTreasury == 0) {
            _serviceFee += fee;
            _frozened += fee;
        } else {
            if (treasuryUCV == address(0)) {
                _serviceFee += fee;
                console.log("serv2:", fee);
                _frozened += fee;
            } else {
                uint8 decimal = _getTokenDecimal(_fund.fundToken);
                uint256 treasuryFee = (percentageToTreasury * fee) /
                    (1 * 10**decimal);
                _serviceFee += (fee - treasuryFee);
                console.log("serv3:", fee);
                console.log("trea4:", treasuryFee);
                console.log("treasury is:", treasuryUCV);

                _transferTo(
                    treasuryUCV,
                    _fund.fundToken,
                    20,
                    0,
                    treasuryFee,
                    comment
                );
                _frozened += _serviceFee;
            }
        }
    }

    function calculateFee(uint256 perc) public view returns(uint256 fee) {

        uint8 decimal = _getTokenDecimal(_fund.fundToken);

        fee = (perc * _totalRaised) / (1 * 10**decimal);

    } 

    function takeFixedFee(address treasuryUCV) internal {
        require(_fixedFeeTransferTime == 0, "Fee already taked");
        // uint8 decimal = _getTokenDecimal(_fund.fundToken);
        // uint256 fixedFee = (_fund.fixedFee * _totalRaised) / (1 * 10**decimal);
        uint256 fixedFee = calculateFee(_fund.fixedFee);
        if (fixedFee > 0) {

            _takeFeeToTreasury(
                treasuryUCV,
                fixedFee,
                _fund.fixedFeeShouldGoToTreasury,
                "income-1"
            );
            
        }
        _fixedFeeTransferTime = block.timestamp;
    }

    function _takePerformanceFee(address treasuryUCV) internal {

        require(_performanceFeeTransferTime == 0, "Fee already taked");

        if (_investmentProfit > 0) {

            uint8 decimal = _getTokenDecimal(_fund.fundToken);
            uint256 fee = (_fund.performanceFee * _investmentProfit) /
                (1 * 10**decimal);

            _takeFeeToTreasury(
                treasuryUCV,
                fee,
                _fund.performanceFeeShouldGoToTreasury,
                "income-1"
            );
        }

        _performanceFeeTransferTime = block.timestamp;
    }

    function getAdminServiceBalance()
        external
        view
        override
        returns (uint256 fee)
    {
        fee = _serviceFee;
    }

    function liquidate() external override {
        _isLiqudating = true;
    }

    function distribute(
        address owner,
        address token,
        uint256 amount
    ) external override {
        _frozened = _frozened - amount;
        _transferTo(owner, token, 20, 0, amount, "");
    }

    function calculateClaimableAmount(address investor, uint256 total)
        external
        view
        override
        returns (uint256 amount)
    {
        return (_originalInvested[investor] * total) / _totalRaised;
    }

    function _issueCertifcate() internal {
        _certificate = address(new InkFundCertificateToken());
        //cut the fee
        if (_fund.fixedFee == 0) {}

        console.log("issued token:", _certificate);
        uint256 value = _getAvailablePrincipal();
        uint8 decimal = _getTokenDecimal(_fund.fundToken);

        InkFundCertificateToken(_certificate).issue(
            _fund.tokenName,
            _fund.tokenName,
            decimal,
            value,
            address(this)
        );
        console.log("balance:", IERC20(_certificate).balanceOf(address(this)));
    }

    function _getTokenDecimal(address token) internal view returns (uint8 decimal) {
        decimal = 18;
        if (token != address(0)) {
            decimal = IERC20Metadata(token).decimals();
        }
    }

    function getCertificateInfo() external view returns (address certificate) {
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
