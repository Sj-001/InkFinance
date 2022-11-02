//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVManager.sol";

interface IPayrollManager is IUCVManager {
    struct PaymentInfo {
        /// @dev which token to pay
        address token;
        /// @dev how many token pay everytime
        uint256 oncePay;
        /// @dev last payID user claimed
        uint256 lastClaimedPayID;
        /// @dev when the user has been add into the schedule
        /// default is 0, means it's inherit from the schedule start time
        uint256 addedTimestamp;
        /// @dev when the user has been removed from the schedule
        uint256 removedTimestamp;
    }

    struct PayrollSettings {
        /// @dev unique payroll schedule id in a PayrollManager
        uint256 scheduleID;
        uint256 startTime;
        uint256 claimPeriod;
        uint256 payTimes;
        uint256 payrollType;
    }

    /// @notice when user claim payroll, this event will be emit
    /// @dev once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.
    /// @param scheduleID the payroll schedule id
    /// @param claimAddress claim token's address
    /// @param claimedBatches how many batchs claimed
    /// @param total how many token claimed
    /// @param token which token has been claimed
    /// @param lastPayID lastPayID
    event PayrollClaimed(
        address indexed dao,
        uint256 indexed scheduleID,
        address indexed claimAddress,
        address token,
        uint256 total,
        uint256 claimedBatches,
        uint256 lastPayID,
        uint256 claimTime
    );

    /// @notice when a new payroll has been setup, this event will be emit.
    /// @param dao based on which dao
    /// @param scheduleID payroll's ID
    /// @param payrollType 0=scheduled 1=one time 2=direct pay investor, 3=direct pay vault
    /// @param payrollInfo payroll's title|description, etc.
    /// @param startTime first claimable time
    /// @param period period between echo claim
    /// @param claimTimes  how many times could claim under this payroll
    event NewPayrollSetup(
        address indexed dao,
        uint256 indexed payrollType,
        uint256 indexed scheduleID,
        bytes payrollInfo,
        uint256 startTime,
        uint256 period,
        uint256 claimTimes
    );


    /// @notice once the multisigner role sign, this event will pass
    event PayrollSign(
        address indexed dao,
        uint256 indexed scheduleID,
        uint256 indexed payID,
        address signer,
        uint256 signTime
    );

    /// @notice once add member under a payroll, this event will be emit
    /// @param scheduleID passed payroll schedule id
    /// @param payeeAddress wallet address
    /// @param token token address
    /// @param oncePay how many token paid once
    /// @param desc extra infomation
    event PayrollPayeeAdded(
        address indexed dao,
        uint256 indexed scheduleID,
        address indexed payeeAddress,
        address token,
        uint256 oncePay,
        bytes desc
    );

    /// @notice create a new payroll, only operator could do this
    /// @param startTime the payroll manager would load data from that proposal(topic) and create the payroll instance
    /// @param claimTimes the fund from which ucv
    /// @param period the fund from which ucv
    /// @param payeeInfo the fund from which ucv
    function setupPayroll(
        bytes memory payrollInfo,
        uint256 payrollType,
        uint256 startTime,
        uint256 period,
        uint256 claimTimes,
        bytes[] memory payeeInfo
    ) external;

    /// @dev after multi-signer voted, how many batchs of payment under a payroll should be paid
    function signPayID(uint256 scheduleID, uint256 payID) external;

    /// @dev claim payroll from the UCV contract and everytime claimed amount is approved batch(not claimed before) multiply once time payment
    function claimPayroll(uint256 scheduleID) external;

    /// @dev calculate how many time and how many token the user can claim under a proposal's topicID
    function getClaimableAmount(uint256 scheduleID, address claimer)
        external
        view
        returns (
            address token,
            uint256 amount,
            uint256 batches,
            uint256 lastPayID
        );

    /// @dev util function, basically provide the method to calculate how many payIDs and their claim times listed for the signers to sign
    function getPayIDs(
        uint256 scheduleID,
        uint256 startPayID,
        uint256 limit
    ) external view returns (uint256[][] memory payIDs);

    /// @notice check the pay has been signed by all the signers
    function isPayIDSigned(uint256 scheduleID, uint256 payID)
        external
        returns (bool isSigned);

    /// @notice if the signer not signed, return 0
    function getSignTime(
        uint256 scheduleID,
        uint256 payID,
        address signer
    ) external view returns (uint256 signTime);
}
