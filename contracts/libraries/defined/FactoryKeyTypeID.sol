//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev used to represent which kind of contract the factory key point to
library FactoryKeyTypeID {

    // keccak256("FactoryTypeID")
    bytes32 internal constant FACTORY_TYPE_ID =
        0x2ee16ad566e4eda6ce43d2dbc3246bc52bfd29238d275308f043f2b4d69117ab;

    // keccak256("DAOTypeID")
    bytes32 internal constant DAO_TYPE_ID =
        0xdeb63a88d4573ec3359155ef44dd570a22acdf5208f7256d196e6bb7483d1b85;

    // keccak256("AgentTypeID")
    bytes32 internal constant AGENT_TYPE_ID =
        0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845;

    // keccak256("CommitteeTypeID")
    bytes32 internal constant COMMITTEE_TYPE_ID =
        0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;

    // keccak256("UCVTypeID")
    bytes32 internal constant UCV_TYPE_ID =
        0x7f16b5baf10ee29b9e7468e87c742159d5575c73984a100d194e812750cad820;        

    // keccak256("UCVManagerTypeID")
    bytes32 internal constant UCV_MANAGER_TYPE_ID =
        0x9dbd9f87f8d58402d143fb49ec60ec5b8c4fa567e418b41a6249fd125a267101;  



    // keccak256("PropoalHandlerTypeID")
    bytes32 internal constant PROPOSAL_HANDLER_TYPE_ID =
        0x1858c200a95d03e2d42c3cf57541f3bc9a8c8471b5f80b7c26e756d34fbced97;  
         


}
