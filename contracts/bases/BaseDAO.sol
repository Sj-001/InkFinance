//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";


abstract contract BaseDAO is IDeploy, IDAO  {

    // @dev the one who created the DAO
    address ownerAddress;

    string name;
    string describe;
    IERC20 govToken;


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IDAO).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

}
