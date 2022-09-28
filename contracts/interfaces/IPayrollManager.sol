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


    /// @dev create a new payroll based on a proposal
    function setupPayroll(bytes32 proposalID) external;

    /// @dev after multi-signer voted, batch of payment  under a payroll should be paid
    function approvePayrollBatch(bytes32 proposalID, uint256 paymentBatch) external;

    /// @dev claim payroll from the UCV contract
    function claimPayroll(bytes32 proposalID, uint256 paymentBatch) external;

    /// @dev return payroll batches
    function getPayrollBatch(bytes32 proposalID, uint256 limit) external returns(PayrollBatchInfo[] memory batchs);




}
