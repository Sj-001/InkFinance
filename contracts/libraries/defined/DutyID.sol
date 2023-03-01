//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DutyID {
    // keccak256("dutyID.DAO_ADMIN")
    bytes32 internal constant DAO_ADMIN =
        0x4575c11fbfaf5400e74dbe9f6f86279ce134d6214445926cc50dccd877e75fa2;

    // keccak256("dutyID.PROPOSER")
    bytes32 internal constant PROPOSER =
        0x4575c11fbfaf5400e74dbe9f6f86279ce134d6214445926cc50dccd877e75fa2;

    // keccak256("dutyID.VOTER")
    bytes32 internal constant VOTER =
        0x241f6fe66d0c676e71b48b26e0b0ddb2dede4dca4534df353a6391c3d6d695e2;

    // keccak256("dutyID.SIGNER")
    bytes32 internal constant SIGNER =
        0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f;

    // keccak256("dutyID.OPERATOR")
    bytes32 internal constant OPERATOR =
        0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4;

    // keccak256("dutyID.AUDITOR")
    bytes32 internal constant AUDITOR =
        0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb;

    // keccak256("dutyID.INVESTOR")
    bytes32 internal constant INVESTOR =
        0xfbc390bb4ea3b52619dc9b8204861b1badcad7b3f4969737509cb97638b81fb0;

    bytes32 internal constant FUND_ADMIN =
        0xb75d7773ce9de3cac72d14cb2c729061aadc554a64d0c817461ca96ed1c371cc;

    bytes32 internal constant FUND_MANAGER =
        0x8560d55e9d80cf71a32b13f2f90e14e78fb5cf9fe10bdee0d2dcb98ff74736e9;

    bytes32 internal constant FUND_RISK_MANAGER =
        0x01331b55733ae070ed3856e4bfdcc4ecdc7d1f4839e980c658dd4e7983271f84;

    bytes32 internal constant FUND_LIQUIDATOR =
        0x8fddb24da2ad50c84cbc7274875caf404a835b89c6694666b5e74523abde0ce8;

    bytes32 internal constant FUND_AUDITOR =
        0xbec75964fc7b92f671de9c0fe87cc5194cb0c8193f09af9794c0140ec4585600;
}
