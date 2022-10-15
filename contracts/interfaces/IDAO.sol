//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IProcessHandler.sol";
import "./IProposalHandler.sol";
import "./IAgentHandler.sol";
import "./ICommittee.sol";
import "./IDutyControl.sol";

error DAO_error1();
/// @dev when operate the committee which does not exist in the DAO, this error will be reported
error CommitteeIsNotExist();
error SystemError();
error NotAllowedToOperate();
error AgentCannotBeExecute();

interface IDAO is
    IProposalHandler,
    IDutyControl,
    IAgentHandler,
    IProcessHandler
{
    /// event

    event NewDAOCreated(
        address indexed owner,
        address indexed token,
        string daoName,
        string daoLogo,
        uint256 createTime
    );

    struct CallbackData {
        address addr;
        address admin;
        address govTokenAddr;
        string name;
    }

    struct DAOCommitteeWithDuty {
        string committeeName;
        address committee;
        bytes32[] duties;
    }

    // /// @dev let agent call any DAO method
    // /// @param contractAddress ask DAO to call the contractAddress
    // /// @param functionSignature the function signatures
    // /// @return success if the call succeed
    // /// @return returnedBytes the returned bytes from the contract function call
    // function callFromDAO(
    //     address contractAddress,
    //     bytes memory functionSignature
    // ) external returns (bool success, bytes memory returnedBytes);

    /// @dev check the account has badges or not
    function hasDAOBadges(address account)
        external
        view
        returns (bool hasBadges);

    /// @notice verify if the account could vote
    /// @dev if dao dao require the badeges to vote or enought pledged tokens
    function allowToVote(address account) external view returns (bool isAllow);

    /// @dev add a new workflow, noramll call by agent
    function setupFlowInfo(FlowInfo memory flow) external;

    /// @dev ge flow steps
    function getFlowSteps(bytes32 flowID)
        external
        view
        returns (CommitteeInfo[] memory infos);

    /// @dev setup a new payroll UCV
    /// @param proposalID the ucv based on which proposal
    /// @param controller the contract controller address
    /// @param ucvKey the ucv deploy key
    /// @param managerKey the manager deploy key
    function setupPayrollUCV(bytes32 proposalID, address controller, bytes32 ucvKey, bytes32 managerKey) external;

    /// @notice when payroll pay propal passed, agent call will call this function to approve the paymenta
    function payrollPaymentApprove(
        bytes32 proposalID,
        uint256 approveTimes,
        address managerAddress
    ) external;

    function deployByKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) external returns (address deployedAddress);

    /// @notice return all commitees and it's dutyIDs
    /// @return committeeDuties return the committee's dutyID as array
    function getDAOCommittees()
        external
        view
        returns (DAOCommitteeWithDuty[] memory committeeDuties);
}
