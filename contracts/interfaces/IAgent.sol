//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAgentInfo.sol";

interface IAgent is IAgentInfo {
    // 初始化方法, 传入DAO的地址, 虽然原则上来说, msg.sender就是dao, 但考虑
    // 其他方式的初始化设定, 可能msg.sender并发dao本身, 比如agent设定agent.
    function initAgent(address dao) external;

    /// @dev get agent description
    /// @return description description
    function getDescription() external view returns (string memory description);

    /// @dev pre exec mean check the execute process and see if any problems.
    /// @param proposalID target proposal
    /// @return success true means works
    function preExec(bytes32 proposalID) external returns (bool success);

    /// @dev do run the proposal decision
    /// @param proposalID target proposal
    function exec(bytes32 proposalID) external;

    /// @dev return the flow of the agent
    /// @return flowID the flow of the agent
    function getAgentFlow() external returns (bytes32 flowID);
}
