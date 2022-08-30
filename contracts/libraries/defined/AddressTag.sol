//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// used to address registry "tag".
library AddressTag {
    ////////// general address tag

    // keccak256("addresstag.FACTORY_DAO")
    bytes32 internal constant FACTORY_DAO =
        0xec5e7c7d22597af3c657ad4890c44990eedd38c4ded579e8861cf76cfaf77710;

    // keccak256("addresstag.FACTORY_COMMITTEE")
    bytes32 internal constant FACTORY_COMMITTEE =
        0x5fbb49a82d441224cad2457fb305f51502ad3852b680ea16eacd466963435777;

    // keccak256("addresstag.FACTORY_STAKING")
    bytes32 internal constant FACTORY_STAKING =
        0x2ef726b60357012067f48f4e8a81bc01de5a66db46ed50e0f8d2b76820083dc4;

    // keccak256("addresstag.PLATFORM_CONTRACT")
    bytes32 internal constant PLATFORM_CONTRACT =
        0x91a8d7c064f8743fa23b014b49b355c9932e36dce614d2581c438902082503cc;

    // keccak256("addresstag.DISABLE")
    bytes32 internal constant DISABLE =
        0x039aba4e990513d126854e7bb2559c7b9c24dd3e71fd9a4caf47a43b6ee754b5;
}
