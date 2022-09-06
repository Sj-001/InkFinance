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

    /// @dev contractID=>DeployableContract
    mapping(bytes32 => DeployableContract) private _deployableContracts;

    mapping(bytes32 => EnumerableSet.AddressSet) private _deployedContracts;

    /// @dev config address
    address private _config;


     function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return true;
     }


    constructor(address config_) {
        super.init(config_);

        console.log("initialize config:");
        console.log(config_);
        _config = config_;
        proxy = new InkProxy();
    }


    /// @inheritdoc IFactoryManager
    function addContract(bytes32 contractID, address contractImpl)
        external
        override
    {
        require(
            // IConfig(_config).hasRole(
            //     BEACON_UPGRADER_ROLE,
            //     msg.sender
            // ),
            true,
            "not allowed to add contract"
        );

        DeployableContract storage deployableContract = _deployableContracts[
            contractID
        ];
        // require(deployableContract.link._isEmpty(), "this contract is already exist");
        deployableContract.inkBeacon = new InkBeacon(contractImpl, _config);
        emit AddContract(
            contractID,
            deployableContract.inkBeacon.implementation(),
            contractImpl
        );
    }

    /// @inheritdoc IFactoryManager
    function delContract(bytes32 contractID) external override {
        // require(
        //     IConfig(_config).hasRole(
        //         BEACON_UPGRADER_ROLE,
        //         msg.sender
        //     ),
        //     "not allowed to del contract"
        // );
        emit DelContract(contractID);
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
        /*
        console.log("new deploy:");
        console.log(
            "implementation deploy:",
            deployableContract.inkBeacon.implementation()
        );
        console.log("generated deploy:", generatedContract);

        // emit NewDeploy(
        //     contractID,
        //     deployableContract.inkBeacon.implementation(),
        //     generatedContract,
        //     initData,
        //     msg.sender
        // );
        */
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
