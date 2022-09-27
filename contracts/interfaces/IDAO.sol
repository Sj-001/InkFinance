//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IProposalHandler.sol";
import "./IAgentHandler.sol";
import "./ICommittee.sol";
import "./IDutyControl.sol";

error DAO_error1();
/// @dev when operate the committee which does not exist in the DAO, this error will be reported
error CommitteeIsNotExist();
error SystemError();
error NotAllowedToOperate();

interface IDAO is IProposalHandler, IDutyControl, IAgentHandler {
    struct CallbackData {
        address addr;
        address admin;
        address govTokenAddr;
        string name;
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

    /// @dev add a new workflow, noramll call by agent
    function setupFlowInfo(FlowInfo memory flow) external;

    /// @dev ge flow steps
    function getFlowSteps(bytes32 flowID)
        external
        view
        returns (CommitteeInfo[] memory infos);

    /// @dev setup a new UCV
    function setupUCV(address controller, bytes32 contractKey) external;


        function deployByKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData) external returns (address deployedAddress);


    
}
