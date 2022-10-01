//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVController.sol";

interface IPayrollManager {
    /// @dev payroll batch approve info
    /// @param batch payroll batch
    /// @param approved if all the signer voted to approve, approved = 1, otherwise it's 0
    struct PayrollBatchInfo {
        uint256 batch;
        uint256 approved;
    }

    /// @notice when user claim payroll, this event will be emit
    /// @dev once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.
    /// @param proposalID the payroll under which proposal
    /// @param claimAddress claim token's address
    /// @param claimedBatchs how many batchs claimed
    /// @param total how many token claimed
    /// @param token which token has been claimed
    event PayrollClaimed(
        bytes32 indexed proposalID,
        address indexed claimAddress,
        uint256 indexed claimedBatchs,
        uint256 total,
        address token
    );

    /// @notice when a new payroll has been setup, this event will be emit.
    /// @param proposalID based on which proposal
    /// @param claimPeriod claim period between each batch
    /// @param availableTimes how many times could claim under this payroll
    /// @param firstClaimTime first claimable time
    event NewPayrollSetup(
        bytes32 indexed proposalID,
        uint256 claimPeriod,
        uint256 availableTimes,
        uint256 firstClaimTime
    );

    /// @notice once the multisigner role vote and pass the proposal(pay the batch under payroll), this event will be emit
    /// @param proposalID target proposalID
    /// @param batch the batch under the payroll
    event ApprovePayrollBatch(
        bytes32 indexed proposalID,
        uint256 indexed batch
    );

    /// @notice once add member under a payroll, this event will be emit
    /// @param proposalID passed payroll proposalID
    /// @param memberAddr wallet address
    /// @param token token address
    /// @param oncePay how many token paid once
    /// @param desc extra infomation
    event PayrollMemberAdded(
        bytes32 indexed proposalID,
        address indexed memberAddr,
        address token,
        uint256 oncePay,
        bytes desc
    );

    /// @notice create a new payroll based on a proposal
    /// @dev only agent could call this
    /// @param proposalID the payroll manager would load data from that proposal and create the payroll instance
    function setupPayroll(bytes32 proposalID) external;

    /// @dev after multi-signer voted, batch of payment  under a payroll should be paid
    function approvePayrollBatch(bytes32 proposalID, uint256 paymentBatch)
        external;

    /// @dev claim payroll from the UCV contract
    function claimPayroll(bytes32 proposalID, uint256 paymentBatch) external;

    /// @dev return payroll batches
    function getPayrollBatch(bytes32 proposalID, uint256 limit)
        external
        returns (PayrollBatchInfo[] memory batchs);
}
