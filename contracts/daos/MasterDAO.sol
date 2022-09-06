//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseDAO.sol";


import "hardhat/console.sol";


contract MasterDAO is BaseDAO {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;


    /// structs ////////////////////////////////////////////////////////////////////////

    /// @notice MasterDAO initial data, when create dao, 
    /// these data is necessary for creating the DAO instance.
    /// @param name DAO name
    /// @param describe DAO's description
    /// @param mds DAO's meta data
    /// @param govTokenAddr DAO's governance token 
    /// @param govTokenAmountRequirement base requirement token amount for createing the DAO
    /// @param stakingAddr DAO's staking engine address
    /// @param flows operate flows of the DAO
    /// @param badgeName the badge name of the DAO
    /// @param badgeTotal how many badges in the DAO
    struct MasterDAOInitData {
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        // FlowInfo[] flows;
        // string badgeName;
        // uint256 badgeTotal;
        // string daoLogo;
        // uint256 minPledgeRequired;
        // uint256 minEffectiveVotes;
        // uint256 minEffectiveVoteWallets;
    }


    
    /// variables ////////////////////////////////////////////////////////////////////////
    /// @dev frontend tools to build init data
    function buildInitData(MasterDAOInitData memory initData)
        public
        pure
        returns (bytes memory data)
    {
        return abi.encode(initData);
    }

    function init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        ownerAddress = admin_;
        // _metadata._init();
        console.log("start:");
        console.logBytes(data);
        
        MasterDAOInitData memory initData = abi.decode(data, (MasterDAOInitData));
        name = initData.name;
        describe = initData.describe;
        govToken = initData.govTokenAddr;
        
        // _metadata._setBytesSlice(initData.mds);
        govTokenAmountRequirement = initData.govTokenAmountRequirement;
        stakingAddr = initData.stakingAddr;

        console.log(name);
        console.log(describe);
        console.log(address(initData.govTokenAddr));
        console.log(govTokenAmountRequirement);
        console.log(stakingAddr);
        console.log("end:");

        // require(initData.flows.length != 0, "no flow set");
        // for (uint256 i = 0; i < initData.flows.length; i++) {
        //     _setFlowStep(initData.flows[i]);
        // }

        // if(bytes(initData.badgeName).length != 0){
        //   _badge = InkBadgeERC20Factory(IAddressRegistry(addrRegistry).getAddress(AddressID.InkBadgeERC20Factory)).CreateBadge(initData.badgeName, initData.badgeName, initData.badgeTotal, admin);

        //   emit EBadge(_badge, initData.name, initData.badgeTotal);
        // }

        // CallbackData memory callbackData;
        // callbackData.addr = address(this);
        // callbackData.admin = admin_;
        // callbackData.govTokenAddr = address(govToken);
        // callbackData.name = name;

        // return abi.encode(callbackData);

    }

    function testDecode(bytes calldata data) public {
        MasterDAOInitData memory initData = abi.decode(data, (MasterDAOInitData));

        console.log(initData.name);
    
    }

}
