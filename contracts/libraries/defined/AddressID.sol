//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// used to address registry "identity".
library AddressID {
    // keccak256("addressid.PROPOSAL_REGISTRY")
    bytes32 internal constant PROPOSAL_REGISTRY =
        0x87efaee144799241a588fa53dd836664613d7c5ceabbb7787bd29c2262b7e667;

    // keccak256("addressid.FACTORY_MANAGER")
    bytes32 internal constant FACTORY_MANAGER =
        0x003023429b257a21bfa9e5e7a37afdecfee587d7bff821048b877f6e00066521;

    // keccak256("addressid.IDENTITY_MANAGER")
    bytes32 internal constant IDENTITY_MANAGER =
        0xdedc99725387842d9a6d638522c2314b746dbde5913bc1159e583a45ccc69bbb;

    // keccak256("addressid.InkBadgeERC20Factory")
    bytes32 internal constant InkBadgeERC20Factory =
      0x2abd799a8b295d39b3f061556093e19cb6777d7346a4a772b80c051d642f1725;

    // ExecuteAgent 地址定义.
    // prefix = keccak256("addressid.ExecuteAgent")
    // agent = keccak256(abi.encode(prefix, agent name));
    bytes32 internal constant EXECUTED_AGENT_PREFIX = 0x7647dfa40b7cac80f0613fa4077233e89aee989841380fad454b7f4367296a31;
}
