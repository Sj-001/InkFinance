//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../interfaces/IConfig.sol";

/// @title Abstract contract BaseVerify
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice base verify is context and initializable (initialize just once)
abstract contract BaseVerify is Context, Initializable {
    IConfig public globalConfig;

    function init(address _config) public initializer {
        globalConfig = IConfig(_config);
        require(
            globalConfig.supportsInterface(type(IConfig).interfaceId),
            "not implement IConfig"
        );
    }

    // modifier IsSysAdmin() {
    //     require(globalConfig.isSysAdmin(_msgSender()), "not sys admin");
    //     _;
    // }
}
