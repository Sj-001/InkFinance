//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "hardhat/console.sol";

/// @title execute a payroll schedule, like make a proposal about a payroll, once the proposal has been passed, everyone could claim the token under that payroll
contract PayrollExecuteAgent is BaseAgent {
    bytes32 private FLOW_ID =
        0xce8413630ab56be005a97f0ae8be1835fb972819fa4327995eb9568c76252d28;

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
            "pre exec --------------------------------------------------------------------------------- "
        );

        // 检查批次是不是到期可以领取
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        console.log(
            "PayrollExecuteAgent exec --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- "
        );

        // 获得 ProposalID 提议 发放的 Payroll 的批次
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

    function turnBytesToBytes32(bytes memory originBytes)
        internal
        pure
        returns (bytes32)
    {
        bytes32 targetBytes32;

        assembly {
            targetBytes32 := mload(add(originBytes, 32))
        }
        return targetBytes32;
    }

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(byteAddress, 32))
        }
    }
}
