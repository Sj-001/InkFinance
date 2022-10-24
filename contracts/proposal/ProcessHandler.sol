//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDeploy.sol";
import "../interfaces/IProcessHandler.sol";

import "../bases/BaseVerify.sol";

import "../utils/BytesUtils.sol";
import "../libraries/defined/DutyID.sol";
import "../libraries/defined/TypeID.sol";

import "hardhat/console.sol";

contract ProcessHandler is IProcessHandler, IDeploy, BaseVerify {

    using Address for address;
    using BytesUtils for bytes;

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;


    /// @notice store the connection between different committee in a flow
    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
    }

    // variables ////////////////////////////////////////////////////////////////////////
    /// @notice limit the vote flow steps at most 10 steps
    uint256 public constant MAX_STEP_NUM = 10;

    
    /// @dev stored proposal
    /// proposalID=>ProposalProgress
    // mapping(bytes32 => ProposalProgress) internal _proposalInfo;


    address private _dao;

    /// @inheritdoc IDeploy
    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // super.init(config_);

        _dao = dao_;
        return callbackEvent;
    }

    /// @inheritdoc IProcessHandler
    function getVoteExpirationTime(bytes32 proposalID)
        external
        view override
        returns (uint256 expiration) {

        }


    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IProcessHandler).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
