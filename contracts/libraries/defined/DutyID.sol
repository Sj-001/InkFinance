//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DutyID {
    // keccak256("dutyID.PROPOSER")
    bytes32 internal constant PROPOSER =
        0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e;

    // keccak256("dutyID.VOTER")
    bytes32 internal constant VOTER =
        0xf579da1548edf1a4b47140c7e8df0e1e9f881c48184756b7f660e33bbc767607;

    // keccak256("dutyID.SIGNER")
    bytes32 internal constant SIGNER =
        0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f;

    // keccak256("dutyID.OPERATOR")
    bytes32 internal constant OPERATOR =
        0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4;

    // keccak256("dutyID.AUDITOR")
    bytes32 internal constant AUDITOR =
        0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb;
}
