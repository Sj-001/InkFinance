//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IProposalInfo.sol";
import "../interfaces/IPayrollManager.sol";

library ProposalHelper {
    function getPayeeMembers(IProposalInfo.Proposal storage self)
        internal
        view
        returns (IPayrollManager.PayrollScheduleMember[] memory payees)
    {}
}
