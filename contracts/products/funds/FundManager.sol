//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IFundManager.sol";
import "../../interfaces/IFund.sol";
import "../../interfaces/IDAO.sol";
import "../../libraries/defined/FactoryKeyTypeID.sol";
import "../../bases/BaseUCVManager.sol";
import "hardhat/console.sol";

error TheAccountIsNotAuthroized(address account);
error DeployFailuer(bytes32 factoryKey);

contract FundManager is IFundManager, BaseUCVManager {
    // using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.Bytes32Set private _fundList;

    /// @dev fundID->Fund address
    mapping(bytes32 => address) private _funds;

    address private _factoryManager;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        super.init(config_);

        console.log("FundManager init called");

        _dao = dao_;

        _factoryManager = IDAO(_dao).getDAODeployFactory();
    }

    // constructor(address factoryManager_) {
    //     _factoryManager = factoryManager_;
    // }

    /// @inheritdoc IFundManager
    function createFund(NewFundInfo memory fundInfo)
        external
        override
        returns (address ucvAddress)
    {
        // authrized
        bytes32 fundID = _newFundID();

        // bytes memory initData = abi.encode(address(this), fundInfo);

        // address fundAddress = _deployByFactoryKey(FactoryKeyTypeID.UCV_TYPE_ID, fundInfo.fundDeployKey, initData);
        // _funds[fundID] = fundAddress;

        console.log(fundInfo.fundName);
        console.logBytes32(fundID);
        console.log(fundInfo.requireClientBiometricIdentity);

        emit FundCreated(
            fundID,
            address(0),
            fundInfo.fundName,
            fundInfo.fundDescription,
            fundInfo
        );
    }

    /// @inheritdoc IFundManager
    function getLaunchStatus(bytes32 fundID)
        external
        override
        returns (uint256 status)
    {}

    /// @inheritdoc IFundManager
    function launchFund(bytes32 fundID) external override {
        // authrized
        IFund(_funds[fundID]).launch();
        // emit FundLaunched();
    }

    /// @inheritdoc IFundManager
    function startFund(bytes32 fundID) external override {
        // authrized
        IFund(_funds[fundID]).launch();
    }

    /// @inheritdoc IFundManager
    function getFundStatus(bytes32 fundID)
        external
        override
        returns (uint256 status)
    {}

    /// @inheritdoc IFundManager
    function geFundShare(bytes32 fundID)
        external
        view
        override
        returns (uint256 share)
    {}

    /// @inheritdoc IFundManager
    function claimFundShare(bytes32 fundID) external override {}

    /// @inheritdoc IFundManager
    function withdrawPrincipal(bytes32 fundID) external override {}

    /// @inheritdoc IFundManager
    function claimPrincipalAndProfit(bytes32 fundID) external override {}

    /// @inheritdoc IFundManager
    function getFund(bytes32 fundID)
        external
        view
        override
        returns (address fundAddress)
    {
        fundAddress = _funds[fundID];
    }

    uint256 private _seed = 0;

    function _newFundID() private returns (bytes32 fundID) {
        _seed++;
        fundID = keccak256(abi.encodePacked(_seed, address(this)));
    }

    /*
    /// @inheritdoc IFundManager
    function claimFundShare(bytes32 proposalID) external override {

        uint256 totalRaised = 0;
         
        uint256 fundIssued = 0;

        uint256 currentPurchased = _fundShare[proposalID][msg.sender];

        uint256 claimableShare = currentPurchased / totalRaised * 100 * fundIssued;

        // transfer
        _fundShare[proposalID][msg.sender] = 0;
        // emit FundShareClaimed()
    }

    function geFundShare(bytes32 proposalID) external override {

    }


    function purchaseFundShare(bytes32 proposalID, uint256 purchaseAmount) external override {
        // maximum purchase check
        uint256 maximum = 0;        
        if (_fundRaised[proposalID] < maximum && _fundRaised[proposalID] + purchaseAmount <= maximum) {

            // 


        }

        _fundRaised[proposalID] += purchaseAmount;
    }


    function withdrawPrincipal(bytes32 proposalID) external override {
        // make sure the proposal is failed
        
    }

    */

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}

    function _deployByFactoryKey(
        bytes32 typeID,
        bytes32 contractKey,
        bytes memory initData
    ) internal returns (address deployedAddress) {
        bytes memory deployCall = abi.encodeWithSignature(
            "deploy(bool,bytes32,bytes32,bytes)",
            true,
            typeID,
            contractKey,
            initData
        );

        (bool _success, bytes memory _returnedBytes) = address(_factoryManager)
            .call(deployCall);

        if (_success) {
            deployedAddress = turnBytesToAddress(_returnedBytes);
        } else {
            revert DeployFailuer(contractKey);
            // console.log("test turn turn bytes 32 ", deployedAddress);
            // console.log("to address ", _returnedBytes.toAddress());
        }
    }

    function turnBytesToAddress(bytes memory byteAddress)
        internal
        pure
        returns (address addr)
    {
        addr = abi.decode(byteAddress, (address));
    }
}
