//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/ICommittee.sol";
import "../interfaces/IDeploy.sol";

import "./BaseVerify.sol";

abstract contract BaseCommittee is IDeploy, ICommittee, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;

    // variables;

    /// @dev belongt to which DAO
    address private _DAO;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(ICommittee).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    function init(
        address admin,
        address config,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {}

    function newProposal(
        Proposal calldata proposal,
        bool commit,
        bytes calldata data
    ) external override returns (bytes32 proposalID) {}

    // used to append new kvData(can convert old same key)
    function changeProposal(
        bytes32 proposalID,
        KVItem[] memory contents,
        bool commit,
        bytes calldata data
    ) external override {}

    // if agree, apply the proposal kvdata to topic.
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external override {}
}
