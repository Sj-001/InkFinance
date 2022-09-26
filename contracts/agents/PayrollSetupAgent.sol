//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "hardhat/console.sol";

/// @title set up a payroll schedule
contract PayrollSetupAgent is BaseAgent {
    bytes32 public FLOW_ID = "";

    function init(
        address dao_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
    }

    /// @inheritdoc IAgent
    function preExec(bytes32 proposalID)
        external
        override
        returns (bool success)
    {
        // valid, if it's proposl, etc.
        console.log(
            "pre exec --------------------------------------------------------------------------------- "
        );
    }

    function _setupUCV(address controller_) internal {
        /// PayrollSetupAgent Key is 0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1
        IDAO(getAgentDAO()).setupUCV(
            controller_,
            0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1
        );
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        console.log("execute pay manager here");
    }

    function getTypeID() external view override returns (bytes32 typeID) {}

    function getVersion() external view override returns (uint256 version) {}

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
