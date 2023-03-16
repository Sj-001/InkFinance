//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./BaseVerify.sol";

import "../interfaces/IDeploy.sol";

abstract contract BaseUCVManager is IDeploy, BaseVerify {
    address internal _dao;

    modifier daoOnly() {
        require(msg.sender == _dao, "DAO only");
        _;
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
}
