//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IAgentInfo is IERC165 {
    // 任意执行接口, 仅能agent调用, 用于代表该DAO执行任意指令.
    // agentID=全F也是调用该接口.
    // 允许批量调用执行, 降低gas消耗.
    struct TxInfo {
        address to;
        uint256 value;
        bytes data;
        uint256 gasLimit;
    }
}
