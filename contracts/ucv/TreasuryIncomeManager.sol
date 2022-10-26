//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../bases/BaseVerify.sol";

import "../interfaces/ITreasuryIncomeManager.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IDutyControl.sol";
import "../libraries/defined/DutyID.sol";

import "hardhat/console.sol";

error NotAuthrizedToCommitReport(address msgSender);
error ThisReportIsAlreadCommitted(uint256 reportID);

contract TreasuryIncomeManager is ITreasuryIncomeManager, BaseVerify {

    event IncomeReport(
        address indexed dao,
        address indexed operator,
        uint256 reportID,
        bytes data,
        uint256 commitTime
    );

    address private _dao;

    uint256 private _startTimestamp;
    uint256 private _auditPeriod;

    uint256 private _proposalID;


    mapping(uint256 => mapping(address => uint256)) _auditRecords;

    mapping(uint256 => uint256) committedReport;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _dao = dao_;
        console.log("initialized ----- ");
        
        (_startTimestamp, _auditPeriod) = abi.decode(data_,(uint256, uint256));
        console.log("start time",_startTimestamp);
        console.log("period time",_auditPeriod);
    }


    function getInitData() public view returns(uint256, uint256, uint256) {
        return (getLatestID(block.timestamp, _startTimestamp, _auditPeriod), _startTimestamp, _auditPeriod);
    }

    function getLatestID(uint256 currentTime, uint256 _startTimestamp, uint256 _auditPeriod)
        public
        view
        returns (uint256 latestPayID)
    {
        
        if (currentTime - _startTimestamp - 1 <= 0) {
            return 0;
        }

        if (currentTime - _startTimestamp - 1 < _auditPeriod) {
            return 1;
        }

        latestPayID =
            ((currentTime - _startTimestamp - 1) / _auditPeriod) +
            1;
    }


    function _getAuditIDs(
        uint256 startID,
        uint256 limit,
        uint256 startTimestamp,
        uint256 auditPeriod
    ) internal view returns (uint256[][] memory auditIDs) {
        console.log("_get audit ids:");
        uint256 auditIDArraySize = limit;
        uint256 lastAuditID = getLatestID(block.timestamp, startTimestamp, auditPeriod);
        console.log("lastAuditID: ", lastAuditID);

        if (lastAuditID == 0) {
            return auditIDs;
        }

        if (lastAuditID == startID) {
            auditIDArraySize = 1;   
        } else {
            auditIDArraySize = lastAuditID - startID + 1;
        }

        if (auditIDArraySize > limit) {
            auditIDArraySize = limit;
        } 

        console.log("start: ",_startTimestamp);
        console.log("period: ", _auditPeriod);
        console.log("auditIDArraySize: ", auditIDArraySize);

        /// @dev availableTime == 0, means unlimited claim
        auditIDs = new uint256[][](auditIDArraySize);

        for (uint256 i = 0; i < auditIDs.length; i++) {
            auditIDs[i] = new uint256[](2);
            auditIDs[i][0] = startID + i;
            auditIDs[i][1] =
                _startTimestamp +
                _auditPeriod *
                (startID + i - 1);
        }
    }

    function getAuditIDs(
        uint256 startID,
        uint256 limit
    ) external view override returns (uint256[][] memory auditIDs) {

        auditIDs = _getAuditIDs(startID, limit, _startTimestamp, _auditPeriod);
    }

    function commitReport(uint256 reportID, bytes memory data) public {

        if (!IDutyControl(_dao).hasDuty(_msgSender(), DutyID.AUDITOR)) {
            revert NotAuthrizedToCommitReport(_msgSender());
        }

        if (isCommittedReport(reportID, msg.sender)) {
            revert ThisReportIsAlreadCommitted(reportID);
        }

        _auditRecords[reportID][msg.sender] = 1;
        emit IncomeReport(_dao, msg.sender, reportID, data, block.timestamp);
    }


    function isCommittedReport(uint256 reportID, address msgSender) public view returns (bool committed) {
        committed = (_auditRecords[reportID][msgSender] == 1);
    }


    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IDeploy).interfaceId;
    }

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}
}
