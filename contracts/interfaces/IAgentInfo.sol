//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IAgentInfo is IERC165 {

    struct TxInfo {
        address to;
        uint256 value;
        bytes data;
        uint256 gasLimit;
    }
}
