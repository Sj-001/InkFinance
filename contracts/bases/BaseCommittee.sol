//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/ICommittee.sol";
import "../interfaces/IDeploy.sol";

import "./BaseVerify.sol";

abstract contract BaseCommittee is IDeploy, ICommittee, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;


    // variables
    /// @dev belong to which DAO
    address private _DAO;

    /// @dev configManager contract
    address private _config;

    /// @dev all committee's duties stored here
    EnumerableSet.Bytes32Set committeeDuties;

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
        address dao_,
        address config_,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {
        _DAO = dao_;
        // committeeDuties.add(keccak256(data));
    }



    /// @inheritdoc ICommittee
    function getCommitteeDuties() external view override returns (bytes32[] memory duties) {

    }

    
}
