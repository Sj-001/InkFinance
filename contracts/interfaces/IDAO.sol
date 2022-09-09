//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IProposalHandler.sol";
import "./IDAOAgent.sol";
import "./ICommittee.sol";
import "./IDutyControl.sol";

error DAO_error1();

interface IDAO is IDAOAgent, ICommittee, IProposalHandler, IDutyControl {
    /// @dev when operate the committee which does not exist in the DAO, this error will be reported
    error CommitteeIsNotExist();

    struct CallbackData {
        address addr;
        address admin;
        address govTokenAddr;
        string name;
    }
}
