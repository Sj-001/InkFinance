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

    /// structs ////////////////////////////////////////////////////////////////////////////////
    struct BaseCommitteeInitData {
        string name;
        string describe;
        bytes[] mds;
        address daoAddress;
    }

    // variables
    /// @dev belong to which DAO
    address internal _parentDAO;

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

    function _init(
        address dao_,
        address config_,
        bytes calldata data
    ) internal {
        super.init(config_);
        // committeeDuties.add(keccak256(data));
    }

    function getParentDAO() internal pure returns (address parentDAO) {
        parentDAO = parentDAO;
    }

    /// @inheritdoc ICommittee
    function getCommitteeDuties()
        external
        view
        override
        returns (bytes32[] memory duties)
    {}
}
