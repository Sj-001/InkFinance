//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IPayrollManager.sol";

import "hardhat/console.sol";
import "../utils/BytesUtils.sol";

/// @title execute a payroll schedule, like make a proposal about a payroll, once the proposal has been passed, everyone could claim the token under that payroll
contract PayrollExecuteAgent is BaseAgent {
    using BytesUtils for bytes;
    bytes32 private FLOW_ID =
        0xce8413630ab56be005a97f0ae8be1835fb972819fa4327995eb9568c76252d28;

    address private _ucvManager;

    function getAgentFlow() external virtual override returns (bytes32 flowID) {
        return FLOW_ID;
    }

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
            "pre exec PayrollExecuteAgent --------------------------------------------------------------------------------- "
        );

        /// @dev valid how many batch could be approved and how many time
        /// this proposl suggest to approve
        /// make sure this time suggested approve times should be less than available times

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());

        bytes32 typeID;
        bytes memory bytesData;
        bytes memory timeBytes;

        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "topicID"
        );

        bytes32 topicID = bytesData.toBytes32();
        console.log("read from the proposal:");
        console.logBytes32(proposalID);
        console.log("topic id:");
        console.logBytes(bytesData);

        (typeID, timeBytes) = proposalHandler.getTopicKVdata(
            topicID,
            "startTime"
        );

        uint256 startTime = abi.decode(timeBytes, (uint256));
        console.log("start time:", startTime);

        (typeID, timeBytes) = proposalHandler.getTopicKVdata(topicID, "period");
        uint256 period = abi.decode(timeBytes, (uint256));
        console.log("period time:", period);

        (typeID, timeBytes) = proposalHandler.getTopicKVdata(
            topicID,
            "claimTimes"
        );

        uint256 claimTimes = abi.decode(timeBytes, (uint256));
        console.log("claim time:", claimTimes);

        success = true;
    }

    /// only DAO could execute
    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());
        console.log(
            "PayrollExecuteAgent exec --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- "
        );

        // 获得 ProposalID 提议 发放的 Payroll 的批次
        bytes32 typeID;
        bytes memory bytesData;
        bytes memory timeBytes;

        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "topicID"
        );

        bytes32 topicID = bytesData.toBytes32();
        (typeID, timeBytes) = proposalHandler.getTopicKVdata(
            topicID,
            "approveTimes"
        );
        uint256 approveTimes = abi.decode(timeBytes, (uint256));

        console.log("approve times", approveTimes);
        // call UCVManager to approve the payroll

        (typeID, timeBytes) = proposalHandler.getTopicKVdata(
            topicID,
            "managerAddress"
        );
        address managerAddress = abi.decode(timeBytes, (address));

        IDAO(getAgentDAO()).payrollPaymentApprove(
            topicID,
            approveTimes,
            managerAddress
        );
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
