//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../bases/BaseUCVManager.sol";
import "../interfaces/IPayrollManager.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IUCV.sol";

import "../libraries/defined/DutyID.sol";

import "hardhat/console.sol";

error TheAccountIsNotAuthroized(address account);
error PayIDIsIllegal(uint256 inputPayID, uint256 availablePayID);
error AlreadySigned();
error HaveToSignThePreviousPay();
error ThePayeeIsAlreadyExist(address payee);
error ThePayeeNeedToClaimThePreviousPaymentFirst(address payee);
error ThePayeeIsNotInThePayroll(address payee);
error ThisPayrollScheduleDoesNotExist(uint256 scheduleID);
error StartPayIDWrong();
error PayeeNotUCVContract(address payee);

error TheMemberIsNotInvestors(address payee);

contract InvestmentUCVManager is BaseUCVManager {
    // using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address private _ucv;

    bytes32 private _investmentSetupProposal;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        super.init(config_);

        _dao = dao_;
        // @dev init proposal
        (_investmentSetupProposal) = abi.decode(data_, (bytes32));

        console.log("InvestmentUCVManager has been initialized");
    }

    // function setUCV(address ucv_) external override {
    //     if (msg.sender != _dao) {
    //         revert TheAccountIsNotAuthroized(msg.sender);
    //     }

    //     _ucv = ucv_;
    // }

    // function _send(address payable _to) public payable {
    //     // Call returns a boolean value indicating success or failure.
    //     // This is the current recommended method to use.
    //     (bool sent, bytes memory data) = _to.call{value: msg.value}("");
    //     require(sent, "Failed to send Ether");
    // }

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}
}
