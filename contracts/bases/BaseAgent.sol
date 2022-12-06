//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseVerify.sol";

import "../interfaces/IAgent.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IProposalInfo.sol";

abstract contract BaseAgent is IDeploy, IAgent, IProposalInfo, BaseVerify {
    /// @notice the description of the agent;
    string private _description;

    bool internal _executed;
    /// @dev
    address private _parentDAO;

    modifier onlyCallFromDAO() {
        require(_msgSender() == _parentDAO, "MsgSender is not DAO");
        _;
    }

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

    function getAgentFlow() external virtual override returns (bytes32 flowID) {
        return 0x0;
    }

    function isExecuted()
        external
        view
        virtual
        override
        returns (bool executed)
    {
        executed = _executed;
    }
}
