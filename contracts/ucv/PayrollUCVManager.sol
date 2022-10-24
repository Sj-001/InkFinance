//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../bases/BaseUCVManager.sol";
import "../interfaces/IPayrollManager.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IUCV.sol";
import "../libraries/defined/DutyID.sol";

import "hardhat/console.sol";

error TheAccountIsNotAuthroized(address account);
error PayIDIsIllegal(uint256 inputPayID, uint256 availablePayID);
error AlreadySigned();
error HaveToSignThePreviousPay();
error ThePayeeIsAlreadyExist(address payee);
error ThePayeeNeedToClaimThePreviousPaymentFirst(address payee);
error ThePayeeIsNotInThePayroll(address payee);
error ThisPayrollScheduleDoesNotExist(uint256 scheduleID);
error StartPayIDWrong();


contract PayrollUCVManager is IPayrollManager, BaseUCVManager {

    // using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct PayrollSchedule {
        EnumerableSet.AddressSet payees;
        mapping(address => PaymentInfo) payeePaymentInfo;
        /// @dev PayID=>(SignerAddress=>Signed:1)
        mapping(uint256 => mapping(address => uint256)) paymentSigns;
        mapping(address => PaymentInfo) removedPayeePaymentInfo;
    }


    uint256 public constant FIRST_PAY_ID = 1;

    /// @dev how many payroll has been set
    uint256 private _payrollCount;

    address private _ucv;

    // payroll item
    // ScheduleID=>PayrollSchedule
    mapping(uint256 => PayrollSchedule) private _schedules;

    mapping(uint256 => PayrollSettings) private _payrollSetting;

    /// @dev calculate pay id for schedule, as for the unlimited claim times, use limit to calculate possible time
    /// @return payIDs payIDs[0][0] = payID(1,2,3,4....), payIDs[0][1] = actual claimable time
    function getPayIDs(
        uint256 scheduleID,
        uint256 startPayID,
        uint256 limit
    ) external view override returns (uint256[][] memory payIDs) {


        if (startPayID < FIRST_PAY_ID) {
            revert StartPayIDWrong();
        }

        PayrollSettings memory setting = _payrollSetting[scheduleID];
        /// @dev availableTimes == 0, means unlimited claim times


        if (setting.payTimes > 0 && setting.payTimes < startPayID) {
            return payIDs;
        }

        uint256 payIDArraySize = limit;
        if (limit > setting.payTimes) {
            payIDArraySize = setting.payTimes;
        }

        /// @dev availableTime == 0, means unlimited claim
        payIDs = new uint256[][](payIDArraySize);

        console.log("here:", payIDs.length);
        for (uint256 i = 0; i < payIDs.length; i++) {
            payIDs[i] = new uint256[](2);
            payIDs[i][0] = startPayID + i;
            payIDs[i][1] =
                setting.startTime +
                setting.claimPeriod *
                (startPayID + i - 1);
        }
    }

    /// @dev according to the start timestamp, calculated the lastest payID, which could be sign and claimed
    function getLatestPayID(uint256 scheduleID, uint256 startTimestamp)
        public
        view
        returns (uint256 latestPayID)
    {
        PayrollSettings memory setting = _payrollSetting[scheduleID];
        if (startTimestamp <= setting.startTime) {
            return 0;
        }
        latestPayID =
            ((startTimestamp - setting.startTime - 1) / setting.claimPeriod) +
            1;
        if (setting.payTimes > 0) {
            // means it's limited time payment
            if (latestPayID > setting.payTimes) {
                latestPayID = setting.payTimes;
            }
        }
    }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        super.init(config_);

        _dao = dao_;
        // @dev init controller and manager address
        _ucv = abi.decode(data_, (address));
        console.log("payroll ucv manager has been initialized");
    }

    function setupPayroll(
        bytes memory payrollInfo,
        uint256 payrollType,
        uint256 startTime,
        uint256 period,
        uint256 payTimes,
        bytes[] memory payeeInfo
    ) external override {
        
        if (!IDutyControl(_dao).hasDuty(msg.sender, DutyID.OPERATOR)) {
            revert TheAccountIsNotAuthroized(msg.sender);
        }

        _payrollCount++;

        PayrollSettings storage setting = _payrollSetting[_payrollCount];
        setting.scheduleID = _payrollCount;
        setting.claimPeriod = period;
        setting.payTimes = payTimes;
        setting.startTime = startTime == 0 ? block.timestamp : startTime;

        _addSchedulePayee(setting.scheduleID, payeeInfo, false);

        emit NewPayrollSetup(
            _dao,
            payrollType,
            setting.scheduleID,
            payrollInfo,
            startTime,
            period,
            payTimes
        );
    }

    function addSchedulePayee(uint256 scheduleID, bytes[] memory payees)
        public
    {
        PayrollSettings storage setting = _payrollSetting[_payrollCount];
        if (setting.scheduleID == 0) {
            revert ThisPayrollScheduleDoesNotExist(scheduleID);
        }
        _addSchedulePayee(scheduleID, payees, true);
    }

    function _addSchedulePayee(
        uint256 scheduleID,
        bytes[] memory payees,
        bool addAfterPayroll
    ) private {
        PayrollSchedule storage sc = _schedules[scheduleID];

        for (uint256 i = 0; i < payees.length; i++) {
            (
                address payee,
                address token,
                uint256 oncePay,
                bytes memory desc
            ) = abi.decode(payees[i], (address, address, uint256, bytes));

            address payeeAddress = payee;

            if (sc.payees.contains(payeeAddress)) {
                revert ThePayeeIsAlreadyExist(payeeAddress);
            }

            if (sc.removedPayeePaymentInfo[payeeAddress].oncePay > 0) {
                revert ThePayeeNeedToClaimThePreviousPaymentFirst(payeeAddress);
            }

            sc.payees.add(payeeAddress);
            PaymentInfo storage paymentInfo = sc.payeePaymentInfo[payeeAddress];
            paymentInfo.token = token;
            paymentInfo.oncePay = oncePay;

            if (addAfterPayroll) {
                paymentInfo.addedTimestamp = block.timestamp;
            }

            emit PayrollPayeeAdded(
                scheduleID,
                payeeAddress,
                paymentInfo.token,
                paymentInfo.oncePay,
                desc
            );
        }
    }

    function signPayID(uint256 scheduleID, uint256 payID) external override {
        _checkAvailableToSign(scheduleID, payID, msg.sender);
        PayrollSchedule storage sc = _schedules[scheduleID];
        sc.paymentSigns[payID][msg.sender] = 1;
        emit PayrollSign(scheduleID, payID, msg.sender);
    }

    function _checkAvailableToSign(
        uint256 scheduleID,
        uint256 payID,
        address signer
    ) internal {
        // require duty
        if (!IDutyControl(_dao).hasDuty(signer, DutyID.SIGNER)) {
            revert TheAccountIsNotAuthroized(signer);
        }

        uint256 latestAvailablePayID = getLatestPayID(
            scheduleID,
            block.timestamp
        );
        if (payID <= 0 && payID > latestAvailablePayID) {
            revert PayIDIsIllegal(payID, latestAvailablePayID);
        }

        PayrollSchedule storage schedule = _schedules[scheduleID];
        if (schedule.paymentSigns[payID][signer] == 1) {
            revert AlreadySigned();
        }

        // make sure sign the payID time by time
        if (payID > FIRST_PAY_ID) {
            // check if the signer signed previous payID
            if (schedule.paymentSigns[payID - 1][signer] == 0) {
                revert HaveToSignThePreviousPay();
            }
        }
    }

    function isPayIDSigned(uint256 scheduleID, uint256 payID)
        external
        view
        override
        returns (bool isSigned)
    {
        isSigned = _isPayIDSigned(scheduleID, payID);
    }

    function _isPayIDSigned(uint256 scheduleID, uint256 payID)
        internal
        view
        returns (bool allSignerSigned)
    {
        PayrollSchedule storage sc = _schedules[scheduleID];
        uint256 signerCount = IDutyControl(_dao).getDutyOwners(DutyID.SIGNER);
        allSignerSigned = false;
        for (uint256 i = 0; i < signerCount; i++) {
            // just make sure everyone signed
            address signer = IDutyControl(_dao).getDutyOwnerByIndex(
                DutyID.SIGNER,
                i
            );

            if (sc.paymentSigns[payID][signer] == 0) {
                return false;
            }
        }
        allSignerSigned = true;
    }

    /// @inheritdoc IPayrollManager
    function claimPayroll(uint256 scheduleID) external override {
        PayrollSchedule storage schedule = _schedules[scheduleID];
        // make sure it's member
        (
            address token,
            uint256 amount,
            uint256 claimBatches,
            uint256 lastPayID
        ) = _getClaimableAmount(scheduleID, msg.sender);

        if (amount > 0) {
            PaymentInfo storage paymentInfo = schedule.payeePaymentInfo[
                msg.sender
            ];
            paymentInfo.lastClaimedPayID = lastPayID;
            emit PayrollClaimed(
                scheduleID,
                msg.sender,
                token,
                amount,
                claimBatches,
                lastPayID
            );
        }

        // IUCV(_payrollUCVs[topicID]).transferTo(
        //     msg.sender,
        //     token,
        //     leftAmount,
        //     abi.encode("")
        // );
    }

    /// @inheritdoc IPayrollManager
    function getClaimableAmount(uint256 scheduleID, address claimer)
        external
        view
        override
        returns (
            address token,
            uint256 amount,
            uint256 batches,
            uint256 lastPayID
        )
    {
        return _getClaimableAmount(scheduleID, claimer);
    }

    function _getClaimableAmount(uint256 scheduleID, address claimer)
        internal
        view
        returns (
            address token,
            uint256 amount,
            uint256 batches,
            uint256 lastPayID
        )
    {
        PayrollSchedule storage schedule = _schedules[scheduleID];
        if (!schedule.payees.contains(claimer)) {
            revert ThePayeeIsNotInThePayroll(claimer);
        }

        uint256 payeeLastClaimedID = schedule
            .payeePaymentInfo[claimer]
            .lastClaimedPayID;

        uint256 lastSignablePayID = getLatestPayID(scheduleID, block.timestamp);

        uint256 lastSignedPayID = 0;

        for (uint256 i = lastSignablePayID; i >= FIRST_PAY_ID; i--) {
            if (_isPayIDSigned(scheduleID, i)) {
                lastSignedPayID = i;
                break;
            }
        }

        uint256 claimBatches = 0;
        if (lastSignedPayID > 0 && lastSignedPayID > payeeLastClaimedID) {
            claimBatches = lastSignedPayID - payeeLastClaimedID;
        }

        if (claimBatches > 0) {
            return (
                schedule.payeePaymentInfo[claimer].token,
                schedule.payeePaymentInfo[claimer].oncePay * claimBatches,
                claimBatches,
                lastSignedPayID
            );
        }

        return (
            schedule.payeePaymentInfo[claimer].token,
            0,
            0,
            lastSignedPayID
        );
    }
    
    function isSigned(uint256 scheduleID, uint256 payID, address signer) external view override returns (bool isSigned) {
        PayrollSchedule storage schedule = _schedules[scheduleID];
        if (schedule.paymentSigns[payID][signer] == 1) {
            isSigned = true;
        } else {
            isSigned = false;
        }
    }

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}
}
