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
        bytes data,
        uint256 commitTime
    );

    address private _dao;

    mapping(uint256 => uint256) committedReport;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _dao = dao_;
        console.log("initialized ----- ");



    }

    function commitReport(uint256 reportID, bytes memory data) public {
        if (!IDutyControl(_dao).hasDuty(_msgSender(), DutyID.AUDITOR)) {
            revert NotAuthrizedToCommitReport(_msgSender());
        }

        if (committedReport[reportID] > 0) {
            revert ThisReportIsAlreadCommitted(reportID);
        }

        emit IncomeReport(_dao, msg.sender, data, block.timestamp);
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
