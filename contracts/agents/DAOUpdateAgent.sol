//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IPayrollManager.sol";
import "../utils/BytesUtils.sol";
import "hardhat/console.sol";

/// @title DAOUpdateAgent
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice DAOUpdateAgent is a delegate to update DAO's base info.
contract DAOUpdateAgent is BaseAgent {
    using BytesUtils for bytes;

    bytes32 public FLOW_ID = keccak256("dao-update-agent");

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
        success = true;
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

    function isUniqueInDAO() external pure override returns (bool isUnique) {
        isUnique = false;
    }
}
