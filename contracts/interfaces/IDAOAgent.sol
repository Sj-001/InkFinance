//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IAgent.sol";

interface IDAOAgent is IAgent {


    /// Agent Related
    // 获取该DAO中, 该agentID对应的代理地址.
    function getAgentIDAddr(bytes32 agentID) external returns (address addr);

    // 指定proposalID, 并且最多执行多少个agent.
    function continueExec(bytes32 proposalID, uint256 agentNum) external;

    // 不检查agentID是否存在, 直接映射即可.
    // 仅能自己调用自己.
    function setAgentFlowID(bytes32 agentID, bytes32 flowID) external;

    function getAgentFlowID(bytes32 agentID) external returns (bytes32 flowID);

    function execTx(TxInfo[] memory txs) external;

}
