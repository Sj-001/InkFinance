//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseUCVManager.sol";


contract PayrollUCVManager is BaseUCVManager{

    
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

    // address private _dao;

    // address private _ucv;

    // payroll item
    // PropsalID(payroll setup Proposal)=>ScheduleInfo
    mapping(bytes32 => Schedule) private _schedules;


    function init(
        address admin,
        address config,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {

    }


    function getTypeID() external override returns (bytes32 typeID) {

    }

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {

    }
}
