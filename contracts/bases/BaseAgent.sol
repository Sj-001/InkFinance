//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAgent.sol";
import "../interfaces/IDeploy.sol";

abstract contract BaseAgent is IDeploy, IAgent {
    /// @notice the description of the agent;
    string private _description;

    /// @dev
    address private _parentDAO;

    /// @inheritdoc IAgent
    function initAgent(address dao_) external override {
        _parentDAO = dao_;
    }

    /// @inheritdoc IAgent
    function getDescription()
        external
        view
        override
        returns (string memory description)
    {
        description = _description;
    }

    function getAgentDAO() internal view virtual returns (address parentDAO) {
        parentDAO = _parentDAO;
    }
}
