//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./KYCVerifyManager.sol";

/// @title KYCVerifyManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice KYCVerifyManager is used to verify signature
contract KYCVerifyManager {

    using ECDSA for bytes32;

    address private _signer;
    address private _config;

    constructor(address config_) {
        _config = config_;
    }


    // 0xf46B1E93aF2Bf497b07726108A539B478B31e64C
    function registerUser(bytes memory signature, bytes memory signData) external {
        // require(_verify(signature, signData, _signer), "sign is invalid");
        
    
    
    }


    function _verify(bytes memory signature, bytes32 data, address account) internal pure returns (bool) {
        return data
            .toEthSignedMessageHash()
            .recover(signature) == account;
    }
}
