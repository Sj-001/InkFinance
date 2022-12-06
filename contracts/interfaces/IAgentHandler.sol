//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IAgentInfo.sol";

interface IAgentHandler is IAgentInfo {
    function getAgentIDAddr(bytes32 agentID) external returns (address addr);

    function continueExec(bytes32 proposalID, uint256 agentNum) external;

    function setAgentFlowID(bytes32 agentID, bytes32 flowID) external;

    function getAgentFlowID(bytes32 agentID) external returns (bytes32 flowID);

    function execTx(TxInfo[] memory txs) external;
}
