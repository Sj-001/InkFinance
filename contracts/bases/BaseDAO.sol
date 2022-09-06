//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";

import "./BaseVerify.sol";

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify  {

    // libs
    using EnumerableSet for EnumerableSet.AddressSet;


    // @dev the one who created the DAO
    address ownerAddress;

    string name;
    string describe;
    IERC20 govToken;


    /// @dev key is dutyID 
    /// find duty members according to dutyID,
    mapping(uint256=>EnumerableSet.AddressSet) private _dutyMembers;



    function init(
        address admin,
        address addrRegistry,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        
    }




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
 