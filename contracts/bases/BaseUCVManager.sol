//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDeploy.sol";

abstract contract BaseUCVManager is IDeploy {

    address private _dao;

    address private _ucv;


    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IDeploy).interfaceId;
    }
}
