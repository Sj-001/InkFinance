//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// used in metadata item type.
library TypeID {
    //////////////////// bytes32 id
    // keccak256("type.ADDRESS")
    bytes32 internal constant ADDRESS =
        0x0ca6d1ca587690485d6a434c34e5e1a8c625f87d47b2073438e0da9b8cd5e7a4;

    // keccak256("type.UINT256")
    bytes32 internal constant UINT256 =
        0x1a330eb57eeaeece41f22ce789ccc758bd5ebd0c144eee7d5a1e93a884c80c12;

    /* keccak256("type.ADDRESS[]"); */
    bytes32 internal constant ADDRESS_SLICE =
        0x100736460f1973acb7722a13b56f289c66801ac691257810b6b8c1236aa0dd27;

    /* keccak256("type.Bytes32"); */
    bytes32 internal constant BYTES32 =
        0x2c47c0fa9d746ea80bdd45fbe8c1a28a65808ed7f5eca2dc3f6ead835fc7d468;
    /* keccak256("type.BOOL"); */
    /* keccak256("type.STRING"); */
}
