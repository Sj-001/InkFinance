//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

// import "../abstract/BaseDeployable.sol";

import "../interfaces/IFactoryManager.sol";
import "../interfaces/IDeploy.sol";
import "../utils/BytesUtils.sol";

import "../proxy/InkBeacon.sol";
import "../proxy/InkProxy.sol";
// import "./SandBox.sol";

import "hardhat/console.sol";

error WrongTypeOfTheFactoryKey();

/// @title FactoryManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice Factory is used to generate DAO instance
contract FactoryManager is BaseVerify, IFactoryManager {
    // using LChainLink for LChainLink.Link;
    using BytesUtils for bytes;

    /// @dev only for test
    using EnumerableSet for EnumerableSet.AddressSet;

    struct DeployableContract {
        uint256 disable;
        InkBeacon inkBeacon;
    }

    InkProxy proxy;

    /// @dev only for test
    mapping(bytes32 => EnumerableSet.AddressSet) private _deployedContracts;

    /// @dev config address
    address private _config;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return interfaceId == type(IFactoryManager).interfaceId;
    }

    constructor(address config_) {
        super.init(config_);
        console.log("initialize config:");
        console.log(config_);
        _config = config_;
        proxy = new InkProxy();
    }

    function _getPredictAddress(
        bytes32 typeID,
        bytes32 contractKey,
        address msgSender
    ) internal view returns (address _calculatedAddress) {
        bytes32 salt = keccak256(abi.encode(typeID, contractKey, msgSender));
        address generatedContract = Clones.predictDeterministicAddress(
            address(proxy),
            salt
        );
        return generatedContract;
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

        // if (_typeID != typeID) {
        //     revert WrongTypeOfTheFactoryKey();
        // }

        address afterDeployedAddressPredict = _getPredictAddress(
            _typeID,
            factoryKey,
            msg.sender
        );
        console.log("predict address", afterDeployedAddressPredict);

        if (
            _deployedContracts[factoryKey].contains(afterDeployedAddressPredict)
        ) {
            console.log("already deployed before <ALREADY>");
            return afterDeployedAddressPredict;
        }

        console.log("KEY IS:");
        console.logBytes32(factoryKey);
        console.log("DATA IS:");
        console.logBytes(addressBytes);

        // valid typeID
        address implementAddress = addressBytes.toAddress();
        console.log("implement address:", implementAddress);
        bytes32 salt = keccak256(abi.encode(_typeID, factoryKey, msg.sender));
        address generatedContract = Clones.cloneDeterministic(
            address(proxy),
            salt
        );
        console.log("generated address:", generatedContract);

        InkBeacon inkBeacon = new InkBeacon(implementAddress, _config);
        // miss proxy init
        console.log("start call proxy init");
        InkProxy(payable(generatedContract)).init(
            _config,
            address(inkBeacon),
            ""
        );
        console.log("start call IDeploy init");
        IDeploy(generatedContract).init(msg.sender, _config, initData);
        emit NewContractDeployed(
            typeID,
            factoryKey,
            generatedContract,
            initData,
            msg.sender,
            block.timestamp
        );

        console.log("add to storage", generatedContract);

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
