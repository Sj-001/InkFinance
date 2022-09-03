//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DutyID {
    ////////// general address tag

    // keccak256("dutyID.SIGNER")
    bytes32 internal constant SIGNER =
        0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f;

    // keccak256("dutyID.OPERATOR")
    bytes32 internal constant OPERATOR =
        0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4;

    // keccak256("dutyID.INCOME_AUDITOR")
    bytes32 internal constant INCOME_AUDITOR =
        0x4c7900c6ad2f5c62580b1f634ac85890fe05eabbc693c59592d09e45c76ba646;
}
