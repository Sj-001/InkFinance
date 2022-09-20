//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

// import "../abstract/BaseDeployable.sol";

import "../interfaces/IFactoryManager.sol";
import "../interfaces/IDeploy.sol";
// import "../library/LChainLink.sol";

import "../proxy/InkBeacon.sol";
import "../proxy/InkProxy.sol";
// import "./SandBox.sol";

import "hardhat/console.sol";

/// @title FactoryManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice Factory is used to generate DAO instance
contract FactoryManager is BaseVerify, IFactoryManager {
    // using LChainLink for LChainLink.Link;

    /// @dev only for test
    using EnumerableSet for EnumerableSet.AddressSet;

    struct DeployableContract {
        uint256 disable;
        InkBeacon inkBeacon;
    }

    uint256 private nounce;

    InkProxy proxy;

    /// @dev only for test
    mapping(bytes32 => EnumerableSet.AddressSet) private _deployedContracts;

    /// @dev config address
    address private _config;

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {
        return true;
    }

    constructor(address config_) {
        super.init(config_);

        console.log("initialize config:");
        console.log(config_);
        _config = config_;
        proxy = new InkProxy();
    }

    function getPredictAddress(bytes32 contractID)
        external
        view
        override
        returns (address _calculatedAddress)
    {
        bytes32 salt = keccak256(abi.encode(contractID, nounce));
        address generatedContract = Clones.predictDeterministicAddress(
            address(proxy),
            salt,
            address(this)
        );
        return generatedContract;
    }

    /*
    /// @inheritdoc IFactoryManager
    function deploy(bytes32 contractID, bytes calldata initData)
        external
        override
        returns (address _newContract)
    {
        DeployableContract storage deployableContract = _deployableContracts[
            contractID
        ];
        // require(!deployableContract.link._isEmpty(), "this contract is already exist");
        require(
            deployableContract.disable == 0,
            "this contractID can't be deployed anymore"
        );

        bytes32 salt = keccak256(abi.encode(contractID, nounce));
        address generatedContract = Clones.cloneDeterministic(
            address(proxy),
            salt
        );

        // miss proxy init
        InkProxy(payable(generatedContract)).init(
            _config,
            address(deployableContract.inkBeacon),
            ""
        );

        IDeploy(generatedContract).init(msg.sender, _config, initData);

        _deployedContracts[contractID].add(generatedContract);
        nounce++;

        emit NewContractDeployed(
            contractID,
            deployableContract.inkBeacon.implementation(),
            generatedContract,
            initData,
            msg.sender
        );

        return generatedContract;
    }
    */

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(byteAddress, 20))
        }
    }

    /// @inheritdoc IFactoryManager
    function deploy(
        bytes32 typeID,
        bytes32 factoryKey,
        bytes calldata initData
    ) external override returns (address _newContract) {
        (bytes32 _typeID, bytes memory addressBytes) = configManager.getKV(
            factoryKey
        );

        console.log("KEY IS:");
        console.logBytes32(factoryKey);
        console.log("DATA IS:");
        console.logBytes(addressBytes);

        // valid typeID
        address implementAddress = turnBytesToAddress(addressBytes);
        console.log("implement address:", implementAddress);

        bytes32 salt = keccak256(abi.encode(implementAddress, nounce));
        address generatedContract = Clones.cloneDeterministic(
            address(proxy),
            salt
        );
        console.log("generated address:", generatedContract);
        InkBeacon inkBeacon = new InkBeacon(implementAddress, _config);
        // miss proxy init
        InkProxy(payable(generatedContract)).init(
            _config,
            address(inkBeacon),
            ""
        );

        IDeploy(generatedContract).init(msg.sender, _config, initData);

        nounce++;

        // emit NewContractDeployed(
        //     typeID,
        //     factoryKey,
        //     generatedContract,
        //     initData,
        //     msg.sender,
        //     block.timestamp
        // );

        _deployedContracts[factoryKey].add(generatedContract);

        return generatedContract;
    }

    function getDeployedAddress(bytes32 contractID, uint256 index)
        public
        view
        returns (address contractAddress)
    {
        return _deployedContracts[contractID].at(index);
    }

    

    function getDeployedAddressCount(bytes32 contractID)
        public
        view
        returns (uint256 size)
    {
        return _deployedContracts[contractID].length();
    }
}
