//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IFactoryManager is IERC165 {
    /// @dev when new kind of contractID has been created, this event will be emit
    /// @param contractID each kind of contract have different contractID, reference to the IDeployFactory comment
    /// @param beacon beacon contract
    /// @param contractImpl deployed contract address
    event AddContract(
        bytes32 indexed contractID,
        address indexed beacon,
        address indexed contractImpl
    );

    event DelContract(bytes32 indexed contractID);

    /// @dev when new contract was deployed, the event will be emit.
    /// @param contractID each kind of contract have different contractID
    /// @param contractImpl implementation of the newAddres
    /// @param newAddr genereated new address
    /// @param initData init data
    /// @param msgSender each kind of contract have different contractID, reference to the IDeployFactory comme
    event NewContractDeployed(
        bytes32 indexed contractID,
        address indexed contractImpl,
        address indexed newAddr,
        bytes initData,
        address msgSender
    );

    /// @dev add new contract template or replace the previous contract, only admin can execute this method
    /// @param contractID each kind of contract have different contractID, reference to the IDeployFactory comment
    /// @param contractImpl the contract implement address
    function addContract(bytes32 contractID, address contractImpl) external;

    /// @dev remove contract template, so anyone could deploy that template contract anymore
    /// @param contractID referal to IDeployFactory comment
    function delContract(bytes32 contractID) external;

    /// @dev add new contract template or replace the previous contract, only admin can execute this method
    /// @param contractID each kind of contract have different contractID, reference to the IDeployFactory comment
    /// @param initData the initData of the contract
    /// @return newAddr according to the contractID, genereated new contract address with the same kind
    function deploy(bytes32 contractID, bytes calldata initData)
        external
        returns (address newAddr);

    function getPredictAddress(bytes32 contractID)
        external
        view
        returns (address _calculatedAddress);
}
