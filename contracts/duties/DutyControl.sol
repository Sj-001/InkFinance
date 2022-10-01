//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDutyControl.sol";

contract DutyControl is IDutyControl {
    /// @inheritdoc IDutyControl
    function addDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function remmoveDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function addUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function removeUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function hasDuty(address account, bytes32 dutyID)
        external
        override
        returns (bool exist)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwners(bytes32 dutyID)
        external
        override
        returns (uint256 owners)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        override
        returns (address addr)
    {}
}
