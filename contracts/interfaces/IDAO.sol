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
    IAgentHandler
{
    event NewDAOCreated(
        address indexed owner,
        address indexed token,
        string daoName,
        string govTokenName,
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

    event NewBadgeCreated(address token, string name, uint256 total);

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

    /// @dev after ucv manager created, call this method set ucv's manager
    function setupUCV(address ucv, address ucvManager) external;

    function getUCV() external view returns (address ucv);

    // /// @dev get flow steps
    // function getFlowSteps(bytes32 flowID)
    //     external
    //     view
    //     returns (CommitteeInfo[] memory infos);

    function getDAODeployFactory()
        external
        view
        returns (address factoryAddress);

    /// @dev deploy
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

    /// @dev create committee
    /// @param name committee's name
    /// @param deployKey the deploy key of the committee
    /// @param dutyIDs committee's dutyID
    function setupCommittee(
        string memory name,
        bytes32 deployKey,
        bytes memory dutyIDs
    ) external;


    function getBoardProposalAgreeSeats() external view returns(uint256 minSeats);
    
    function getVoteRequirement() external view returns(uint256 minIndividalVotes, uint256 maxIndividalVotes);
    
    function isDAOAdmin(address user) external view returns(bool);
    
    function getBoardMemberCount() external view returns(uint256 count);

    /// @notice
    /// function updateInfo(uint256 managerPledge, uint256 minimumVote, uint256 minimumWallet, bytes32 voteProcess, bytes memory addedMembers, bytes memory removedMembers) external;
}
