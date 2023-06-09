//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../libraries/defined/DutyID.sol";
import "../utils/BytesUtils.sol";
import "hardhat/console.sol";

contract IncomeManagerSetupAgent is BaseAgent {
    using BytesUtils for bytes;

    address private _dao;

    /// @inheritdoc IDeploy
    function init(
        address dao_,
        address config_,
        bytes calldata
    ) public virtual override returns (bytes memory) {
        super.init(config_);
        _dao = dao_;
    }

    /// @inheritdoc IAgent
    function preExec(bytes32 proposalID)
        external
        view
        override
        returns (bool success)
    {
        bytes32 typeID;
        bytes memory bytesData;

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());
        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "auditStartTime"
        );

        uint256 startTime = abi.decode(bytesData, (uint256));
        if (startTime == 0) {
            return false;
        }

        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "auditPeriod"
        );

        uint256 period = abi.decode(bytesData, (uint256));
        if (period == 0) {
            return false;
        }

        success = true;
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override onlyCallFromDAO {
        if (_executed == true) {
            revert TheAgentIsAlreadyExecuted();
        }

        bytes32 typeID;
        bytes memory bytesData;

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());
        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "auditStartTime"
        );

        uint256 startTime = abi.decode(bytesData, (uint256));

        (typeID, bytesData) = proposalHandler.getProposalKvData(
            proposalID,
            "auditPeriod"
        );

        uint256 period = abi.decode(bytesData, (uint256));

        bytes memory timeData = abi.encode(startTime, period);
        (typeID, bytesData) = proposalHandler.getProposalMetadata(
            proposalID,
            "incomeManagerKey"
        );

        IDAO(getAgentDAO()).deployByKey(
            typeID,
            bytesData.toBytes32(),
            timeData
        );

        /// @dev avoid execute twice
        _executed = true;
    }

    function isExecuted() external view override returns (bool executed) {
        executed = _executed;
    }

    function getTypeID() external pure override returns (bytes32 typeID) {}

    function getVersion() external pure override returns (uint256 version) {
        version = 1;
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

    function isUniqueInDAO() external override returns (bool isUnique) {
        isUnique = true;
    }
}
