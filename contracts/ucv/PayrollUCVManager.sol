//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../bases/BaseUCVManager.sol";
import "../interfaces/IPayrollManager.sol";
import "hardhat/console.sol";

contract PayrollUCVManager is IPayrollManager, BaseUCVManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    event Withdraw(
        uint256 indexed id,
        address indexed addr,
        uint256 indexed hasTimeID,
        uint256 total,
        address coin
    );

    struct ScheduleMember {
        address coin;
        uint256 oncePay;
        uint256 active;
        uint256 hasTimes;
        uint256 maxTimes;
    }

    struct Schedule {
        // member addr -> member.
        mapping(address => ScheduleMember) members;
        uint256 duration;
        uint256 times;
        uint256 startTime;
    }

    // address private _dao;

    // address private _ucv;

    // payroll item
    // PropsalID(payroll setup Proposal)=>ScheduleInfo
    mapping(bytes32 => Schedule) private _schedules;

    // PropsalID(payroll setup Proposal)=>Removed member address
    mapping(bytes32 => EnumerableSet.AddressSet) private _removedMembers;

    // PropsalID(payroll setup Proposal)=>the time to removed member address from the payroll
    mapping(bytes32 => mapping(address => uint256)) private _removedMoment;

    /// @dev proposalID=>payrollBatch=>1=vote passed, 0=not voted yet.
    mapping(bytes32 => mapping(uint256 => uint256))
        private _payrollBatchVoteInfo;

    function init(
        address dao,
        address config,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IPayrollManager
    function setupPayroll(bytes32 proposalID) external override {
        console.log(
            "set up payroll ------------------------------------------------------------------------------------------------------------------------------------------------------------------ "
        );
        Schedule storage schedule = _schedules[proposalID];
    }

    // agent only

    /// @inheritdoc IPayrollManager
    function approvePayrollBatch(bytes32 proposalID, uint256 paymentBatch)
        external
        override
    {
        _payrollBatchVoteInfo[proposalID][paymentBatch] = 1;
    }

    /// @inheritdoc IPayrollManager
    function claimPayroll(bytes32 proposalID, uint256 paymentBatch)
        external
        override
    {}

    /// @inheritdoc IPayrollManager
    function getPayrollBatch(bytes32 proposalID, uint256 limit)
        external
        override
        returns (PayrollBatchInfo[] memory batchs)
    {}

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}
}
