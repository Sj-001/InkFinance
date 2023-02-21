//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

import "./KYCVerifyManager.sol";

/// @title KYCVerifyManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice KYCVerifyManager is used to verify signature
contract KYCVerifyManager {

    using ECDSA for bytes32;

    address private SIGNER = 0xf46B1E93aF2Bf497b07726108A539B478B31e64C;
    address private _config;

    // constructor(address config_) {
    //     _config = config_;
    // }


    // 0xf46B1E93aF2Bf497b07726108A539B478B31e64C
    function registerUser(bytes memory signature_, string memory accountType, string memory account) external {
        // require(_verify(signature, signData, _signer), "sign is invalid");
        
    
        string memory eoa = toAsciiString(0xBbe14Ab2F06Ef9B33DA7da789005b0CD669C7F81);
        string memory at = accountType;
        string memory a = account;
        string memory original = string(abi.encodePacked(accountType,account,0xBbe14Ab2F06Ef9B33DA7da789005b0CD669C7F81));
        bytes32 originalBytes32 = keccak256(abi.encodePacked(accountType,account,0xBbe14Ab2F06Ef9B33DA7da789005b0CD669C7F81));

        address _signer = ecrecovery(original, signature_);
        address _signer2 = originalBytes32
            .toEthSignedMessageHash()
            .recover(signature_);
        console.log("signer:", _signer);
        console.log("signer2:", _signer2 == SIGNER);

        // require(_signer == SIGNER, "Sign is not valid");
    }


    function _verify(bytes memory signature, bytes32 data, address account) internal pure returns (bool) {
        return data
            .toEthSignedMessageHash()
            .recover(signature) == account;
    }




    function _validClaimSign(bytes memory signature_, address token, uint256 landID, uint256 daily) internal {

        // string memory t = toAsciiString(token);
        // string memory i = toString(landID);
        // string memory y = toString(daily);
        // string memory original = string(abi.encodePacked(t,",",i,",",y));

        // address _signer = ecrecovery(original, signature_);
        // require(_signer == SIGNER, "Sign is not valid");
    }


    /// Utils 
    //////////////////////////////////////////////////////////////////////////////////////////
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    function toAsciiString(address x) public returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        string memory r = string(abi.encodePacked("0x",s));
        return r;
    }

    function char(bytes1 b) public returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function ecrecovery(string memory cont, bytes memory sig) public view returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) {
            return address(0);
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        }
        /* prefix might be needed for geth only
        * https://github.com/ethereum/go-ethereum/issues/3731
        */
        string memory prefix = string(abi.encodePacked("\x19Ethereum Signed Message:\n", toString(bytes(cont).length)));
        bytes32 digest = keccak256(abi.encodePacked(prefix, cont));
        return ecrecover(digest, v, r, s);
    }
}
