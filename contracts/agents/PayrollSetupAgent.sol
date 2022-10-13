//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IPayrollManager.sol";
import "../utils/BytesUtils.sol";
import "hardhat/console.sol";

/// @title set up a payroll schedule
contract PayrollSetupAgent is BaseAgent {
    using BytesUtils for bytes;

    bytes32 public FLOW_ID = keccak256("financial-payroll-setup");

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
        console.log("PayrollSetupAgent pre Exec ");
        // make sure there is members.

        success = true;
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        console.log("execute pay manager here");
        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());

        (bytes32 typeID, bytes memory memberBytes) = proposalHandler
            .getProposalKvData(proposalID, "members");

        console.log("member bytes:");
        console.logBytes(memberBytes);
        console.logBytes32(proposalID);

        bytes memory bytesData;
        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "startTime"
        );

        uint256 startTime = abi.decode(bytesData, (uint256));
        console.log("start time: ", startTime);

        bytes32 topicID = proposalHandler.getProposalTopic(proposalID);
        console.log("topicID111");
        console.logBytes32(topicID);

        _setupPayrollUCV(topicID, msg.sender);
    }

    function _setupPayrollUCV(bytes32 topicID, address controllerAddress)
        internal
    {
        // UCVManagerTypeID = "0x9dbd9f87f8d58402d143fb49ec60ec5b8c4fa567e418b41a6249fd125a267101";
        // payrollUCVManager= 0x8856ac0b66da455dc361f170f91264627f70b6333b9103ff6104df3ce47aa4ec
        console.log("start payroll ucv manager create");

        IDAO(getAgentDAO()).setupPayrollUCV(topicID, controllerAddress);
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

    function isUniqueInDAO() external override returns (bool isUnique) {
        isUnique = false;
    }
}
