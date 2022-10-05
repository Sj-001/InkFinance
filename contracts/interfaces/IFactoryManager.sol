//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

error GenerateContractByKeyFailure();

interface IFactoryManager is IERC165 {
    /// @dev when new contract was deployed, the event will be emit.
    /// @param typeID each kind of contract have different contractID
    /// @param factoryKey a contract key stored in the ConfigManager which point to a contract implementation.
    /// @param newAddr genereated new address
    /// @param initData initial data of the contract
    /// @param msgSender contract instance creator
    /// @param timestamp contract deployed time
    event NewContractDeployed(
        bytes32 indexed typeID,
        bytes32 indexed factoryKey,
        address indexed newAddr,
        bytes initData,
        address msgSender,
        uint256 timestamp
    );

    /// @notice generate new contract storage
    /// @param typeID contract type, eg: DAO, committee, agent, etc. use typeID to verify the factoryKey is point to a proper contract address.
    /// @param factoryKey a contract key stored in the ConfigManager which point to a contract implementation.
    /// @param initData the initData of the contract
    /// @return contractAddr according to the factoryKey, genereated new contract address with the same kind proxy contract.
    function deploy(
        bytes32 typeID,
        bytes32 factoryKey,
        bytes calldata initData
    ) external returns (address contractAddr);
}
