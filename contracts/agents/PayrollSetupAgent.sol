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
        // UCVManagerTypeID = "0x9dbd9f87f8d58402d143fb49ec60ec5b8c4fa567e418b41a6249fd125a267101";
        // payrollUCVManager= 0x8856ac0b66da455dc361f170f91264627f70b6333b9103ff6104df3ce47aa4ec
        console.log("start payroll ucv manager create");
        address managerAddress = IDAO(getAgentDAO()).deployByKey(0x9dbd9f87f8d58402d143fb49ec60ec5b8c4fa567e418b41a6249fd125a267101, 0x8856ac0b66da455dc361f170f91264627f70b6333b9103ff6104df3ce47aa4ec, "");
        console.log("payroll ucv manager address:", managerAddress);
        
        /// PayrollSetupAgent Key is 0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1
        IDAO(getAgentDAO()).setupUCV(
            controller_,
            0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1
        
        );
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        console.log("execute pay manager here");


        _setupUCV(msg.sender);
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
