//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IProposalHandler.sol";

error DAO_error1();

interface IDAO is IERC165, IProposalHandler {
    struct CallbackData {
        address addr;
        address admin;
        address govTokenAddr;
        string name;
    }

    struct FlowInfo {
        bytes32 flowID;
        CommitteeInfo[] committees;
    }

    // function addDutyID() external;

    // function addCommitteeDutyID() external;

    function newProposal(
        ProposalApplyInfo calldata proposal,
        bytes calldata data
    ) external returns (bytes32 proposalID);
}
