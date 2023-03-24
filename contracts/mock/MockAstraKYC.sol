//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MockAstraKYC {
    
    mapping(address=>bytes32) private _userVerify;

    constructor() {}

    function verify() external {
        require(_userVerify[msg.sender] == 0x0000000000000000000000000000000000000000000000000000000000000000, "The user already verified");
        _userVerify[msg.sender] = keccak256(abi.encode(msg.sender));
    }


    function isVerified(address user) external view returns(bytes32 verifiedHash) {
        verifiedHash = _userVerify[user];
    }





}
