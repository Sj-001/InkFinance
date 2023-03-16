//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDutyControl {
    event AddDAOMemberDuty(address account, bytes32 dutyID);

    /// Duty Related
    /// @dev add user-defined DutyID, !!! Agent call only
    /// @param dutyID user-defined dutyID, formed by keccak256
    function addDuty(address account, bytes32 dutyID) external;

    /// @dev remove user-defined DutyID, !!! Agent call only
    /// @param dutyID user-defined dutyID, formed by keccak256
    function remmoveDuty(address account, bytes32 dutyID) external;

    // /// @dev add user into the DAO, !!! Agent call only
    // /// @param account target user
    // function addUser(address account) external;

    // /// @dev remove user from the DAO, !!! Agent call only
    // /// @param account target user
    // function removeUser(address account) external;

    /// @dev identity the account have the duty or not
    /// @param account the query account
    /// @param dutyID the target duty
    /// @return exist exist or not
    function hasDuty(address account, bytes32 dutyID)
        external
        view
        returns (bool exist);

    /// @dev find out how many users have this duty
    /// @param dutyID target duty
    /// @param owners amount of the duty owner
    function getDutyOwners(bytes32 dutyID)
        external
        view
        returns (uint256 owners);

    /// @dev get duty holder's address by index, this used to enumerate all user‘s have this duty
    /// @param dutyID target duty
    /// @param index index place
    /// @return addr the address at that index
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        view
        returns (address addr);
}
