//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseAgent.sol";
import "../interfaces/IDAOAgent.sol";

contract DefaultAgent is BaseAgent {
    bytes32 public FLOW_ID = "";

    /// @inheritdoc IAgent
    function preExec(bytes32 proposalID)
        external
        override
        returns (bool success)
    {
        // valid, if it's proposl, etc.
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        /*
            address to;
            uint256 value;
            bytes data;
            uint256 gasLimit;
        */
        TxInfo[] memory txs;
        txs[0] = TxInfo(address(0), 1, bytes(""), 1);
        IDAOAgent(getAgentDAO()).execTx(txs);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IAgent).interfaceId;
    }
}
