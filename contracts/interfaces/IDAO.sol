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
error AgentCannotBeExecute();

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

    function getTallyVoteRules()
        external
        view
        returns (
            uint256 minAgreeRatio,
            uint256 minEffectiveVotes,
            uint256 minEffectiveWallets
        );

    /// @dev setup a new UCV
    /// @param ucvContractKey the contract implemention mapping key in the ConfigManager
    /// @param initData the initial paramters when UCV required, such as controller address, manager address, etc.
    function setupUCV(bytes32 ucvContractKey, bytes memory initData) external;

    function deployByKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) external returns (address deployedAddress);
}
