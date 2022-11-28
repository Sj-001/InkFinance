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
error TheFactoryKeyIsNotExist();
error FailedToGeneraateAddress(
    bool randomSalt,
    bytes32 typeID,
    bytes32 factoryKey,
    address msgSender
);

/// @title FactoryManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice Factory is used to generate DAO instance
contract FactoryManager is BaseVerify, IFactoryManager {
    // using LChainLink for LChainLink.Link;
    using BytesUtils for bytes;

    /// @dev only for testnp
    using EnumerableSet for EnumerableSet.AddressSet;

    struct InitialiedBeacon {
        uint256 initialied;
        uint256 disable;
        InkBeacon inkBeacon;
    }

    InkProxy proxy;

    /// @dev only for test
    mapping(bytes32 => EnumerableSet.AddressSet) private _deployedContracts;

    mapping(address => InitialiedBeacon) implement2beacon;

    /// @dev config address
    address private _config;

    uint256 nounce = 0;

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
        _config = config_;
        proxy = new InkProxy();
    }

    function _getPredictAddress(
        bool randomSalt,
        bytes32 typeID,
        bytes32 contractKey,
        address msgSender
    ) internal view returns (address _calculatedAddress) {
        bytes32 salt = _getSalt(randomSalt, typeID, contractKey, msgSender);
        address generatedContract = Clones.predictDeterministicAddress(
            address(proxy),
            salt
        );

        return generatedContract;
    }

    function _getSalt(
        bool randomSalt,
        bytes32 typeID,
        bytes32 factoryKey,
        address msgSender
    ) internal view returns (bytes32 salt) {
        if (randomSalt) {
            salt = keccak256(
                abi.encode(typeID, factoryKey, msgSender, block.timestamp)
            );
        } else {
            salt = keccak256(abi.encode(typeID, factoryKey, msgSender));
        }
    }

    function _deploy(
        bool randomSalt,
        bytes32 typeID,
        bytes32 factoryKey,
        bytes calldata initData
    ) internal returns (address _newContract) {
        console.log("deploy start ##### ");
        console.logBytes32(factoryKey);

        (bytes32 _typeID, bytes memory addressBytes) = IConfigManager(_config)
            .getKV(factoryKey);

        if (addressBytes.length == 0) {
            revert TheFactoryKeyIsNotExist();
        }
        // if (_typeID != typeID) {
        //     revert WrongTypeOfTheFactoryKey();
        // }
        // require(false, "before predict ");
        address afterDeployedAddressPredict = _getPredictAddress(
            randomSalt,
            _typeID,
            factoryKey,
            msg.sender
        );
        // require(false, "here predict ");
        // console.log("predict address", afterDeployedAddressPredict);

        if (
            _deployedContracts[factoryKey].contains(afterDeployedAddressPredict)
        ) {
            // console.log("already deployed before <ALREADY>");
            return afterDeployedAddressPredict;
        }

        // require(false, "here predict saved ");

        // valid typeID
        address implementAddress = addressBytes.toAddress();

        // require(false, toAsciiString(implementAddress));
        console.log("implement address:", implementAddress);

        bytes32 salt = _getSalt(randomSalt, _typeID, factoryKey, msg.sender);
        address generatedContract = Clones.cloneDeterministic(
            address(proxy),
            salt
        );

        if (generatedContract == address(0)) {
            revert FailedToGeneraateAddress(
                randomSalt,
                typeID,
                factoryKey,
                msg.sender
            );
        }

        console.log("generated address:", generatedContract);

        InitialiedBeacon storage initialied = implement2beacon[
            implementAddress
        ];

        if (initialied.initialied == 0) {
            initialied.inkBeacon = new InkBeacon(implementAddress, _config);
            initialied.initialied = 1;

            implement2beacon[implementAddress] = initialied;
        }

        InkBeacon inkBeacon = implement2beacon[implementAddress].inkBeacon;

        // miss proxy init
        console.log("start call proxy init");

        InkProxy(payable(generatedContract)).init2(
            _config,
            address(inkBeacon),
            ""
        );
        IDeploy(generatedContract).init(msg.sender, _config, initData);

        console.log("after initial called");
        emit NewContractDeployed(
            typeID,
            factoryKey,
            generatedContract,
            initData,
            msg.sender,
            block.timestamp
        );

        // console.log("add to storage", generatedContract);
        _deployedContracts[factoryKey].add(generatedContract);

        console.log("deploy end");
        return generatedContract;
    }

    /// @inheritdoc IFactoryManager
    function deploy(
        bool randomSault,
        bytes32 typeID,
        bytes32 factoryKey,
        bytes calldata initData
    ) external override returns (address _newContract) {
        return _deploy(randomSault, typeID, factoryKey, initData);
    }

    function getDeployedAddress(bytes32 contractID, uint256 index)
        public
        view
        returns (address contractAddress)
    {
        return _deployedContracts[contractID].at(index);
    }

    function clone(bytes32 factoryKey, bytes calldata initData)
        external
        override
        returns (address _newContract)
    {
        (bytes32 _typeID, bytes memory addressBytes) = IConfigManager(_config)
            .getKV(factoryKey);

        if (addressBytes.length == 0) {
            revert TheFactoryKeyIsNotExist();
        }

        address implementAddress = addressBytes.toAddress();
        _newContract = Clones.clone(implementAddress);

        IDeploy(_newContract).init(address(0), _config, initData);
    }

    function getDeployedAddressCount(bytes32 contractID)
        public
        view
        returns (uint256 size)
    {
        return _deployedContracts[contractID].length();
    }

    function toAsciiString(address x) public returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        string memory r = string(abi.encodePacked("0x", s));
        return r;
    }

    function char(bytes1 b) public returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
