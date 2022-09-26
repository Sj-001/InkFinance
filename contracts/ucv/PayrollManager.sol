//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PayrollManager {
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
        // pay time -> signer
        mapping(uint256 => mapping(address => uint256)) signs;
        uint256 ensureSignTime;
        uint256 id;
        uint256 duration;
        uint256 times;
        uint256 startTime;
    }

    address private _dao;

    address private _ucv;

    // payroll item
    // PropsalID(payroll setup Proposal)=>ScheduleInfo
    mapping(bytes32 => Schedule) private _schedules;
}
