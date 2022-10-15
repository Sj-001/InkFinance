//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUCVController.sol";

interface IPayrollManager {

    struct PayrollScheduleMember {
        address memberAddress;
        address token;
        uint256 oncePay;
        string scheduleType;
    }

    /// @dev payroll batch approve info
    /// @param batch payroll batch
    /// @param approved if all the signer voted to approve, approved = 1, otherwise it's 0
    struct PayrollBatchInfo {
        uint256 batch;
        uint256 approved;
    }

    /// @notice when user claim payroll, this event will be emit
    /// @dev once user claim, all claimable batchs(which they not claim before) will be transfer to the user in one time.
    /// @param topicID the payroll under which proposal's topicID
    /// @param claimAddress claim token's address
    /// @param claimedBatchs how many batchs claimed
    /// @param total how many token claimed
    /// @param token which token has been claimed
    event PayrollClaimed(
        bytes32 indexed topicID,
        address indexed claimAddress,
        uint256 indexed claimedBatchs,
        uint256 total,
        address token
    );

    /// @notice when a new payroll has been setup, this event will be emit.
    /// @param topicID based on which proposal's topicID
    /// @param claimPeriod claim period between each batch
    /// @param availableTimes how many times could claim under this payroll
    /// @param firstClaimTime first claimable time
    event NewPayrollSetup(
        bytes32 indexed topicID,
        uint256 claimPeriod,
        uint256 availableTimes,
        uint256 firstClaimTime
    );

    /// @notice once the multisigner role vote and pass the proposal(pay the batch under payroll), this event will be emit
    /// @param topicID target proposalID's topicID
    /// @param batch the batch under the payroll
    event ApprovePayrollBatch(bytes32 indexed topicID, uint256 indexed batch);

    /// @notice once add member under a payroll, this event will be emit
    /// @param topicID passed payroll proposalID's topicID
    /// @param memberAddr wallet address
    /// @param token token address
    /// @param oncePay how many token paid once
    /// @param desc extra infomation
    event PayrollMemberAdded(
        bytes32 indexed topicID,
        address indexed memberAddr,
        address token,
        uint256 oncePay,
        bytes desc
    );

    /// @notice create a new payroll based on a proposal
    /// @dev only agent could call this
    /// @param topicID the payroll manager would load data from that proposal(topic) and create the payroll instance
    /// @param ucv the fund from which ucv
    function setupPayroll(bytes32 topicID, address ucv) external;

    /// @dev after multi-signer voted, how many batchs of payment under a payroll should be paid
    function approvePayrollBatch(bytes32 topicID, uint256 batches) external;

    /// @dev claim payroll from the UCV contract and everytime claimed amount is approved batch(not claimed before) multiply once time payment
    function claimPayroll(bytes32 topicID) external;

    /// @dev calculate how many time and how many token the user can claim under a proposal's topicID
    function getClaimableAmount(bytes32 topicID, address claimer)
        external
        view
        returns (
            uint256 leftTimes,
            uint256 leftAmount,
            address token
        );

    /// @dev return payroll batches
    function getPayrollBatch(bytes32 proposalID, uint256 limit)
        external
        returns (PayrollBatchInfo[] memory batchs);
}
