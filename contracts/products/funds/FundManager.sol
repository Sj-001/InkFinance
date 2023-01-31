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
error TheFundNeedToTallyUp();
error TheFundCanNotWithdrawPrincipalNow();
error CannotClaimShareNow(uint256 currentFundStatus);
error SucceedButRevert(bytes byteData);
error TokenIsNotEnoughToDistribute(address token);
error DistributionAlreadyClaimedBefore(bytes32 distributionID);

contract FundManager is IFundManager, BaseUCVManager {

    // using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _fundList;

    mapping(bytes32=>FundDistribution[]) private _fundDistributions;

    /// DistributionID=>(EOA=>ClaimTime)
    mapping(bytes32 => mapping(address=>uint256)) private _distributionClaimed;

    /// @dev fundID->Fund address
    mapping(bytes32 => address) private _funds;

    address private _factoryManager;
    bytes32 private _setupProposalID;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        super.init(config_);

        console.log("FundManager init called");

        _dao = dao_;
        _setupProposalID = abi.decode(data_, (bytes32));
        _factoryManager = IDAO(_dao).getDAODeployFactory();

    }



    function makeDistribution(bytes32 fundID, string memory remark, DistributionInfo memory distributionTokens) external {
        
        // valid manager

        // valid period & status

        // new ID
        bytes32 distributionID = _newID();
        
        // valid token amount is enough to distribute after all distribution
        // for(uint256 i=0; i<distributionTokens.length;i++) {
        if (!isTokenEnough(fundID, distributionTokens.token, distributionTokens.amount)) {
            revert TokenIsNotEnoughToDistribute(distributionTokens.token);
        }
        // }

        // (uint256 minRaise, uint256 maxRaise, uint256 currentRaised) = InkFund(_fund).getRaisedInfo() 
        // FundDistribution memory distribution = new FundDistribution()
        // distribution.distributionID = distributionID;
        // distribution.token = 

        FundDistribution memory distribution;
        distribution.distributionID = distributionID;
        distribution.token = distributionTokens.token;
        distribution.amount = distributionTokens.amount;

        _fundDistributions[fundID].push(distribution);


        emit DistributionCreated(
            fundID,
            _funds[fundID],
            msg.sender,
            block.timestamp,
            distributionID,
            remark,
            distributionTokens.token,
            distributionTokens.amount
        );
    }

    function isTokenEnough(bytes32 fundID, address token, uint256 amount) internal returns(bool) {
        uint256 currentTokenDistribution = 0;
        for(uint256 i=0;i <_fundDistributions[fundID].length; i++) {
            currentTokenDistribution += _fundDistributions[fundID][i].amount;
            // for(uint256 j=0;j <_fundDistributions[i].distributionTokens.length; j++) {
            //     if (true) {
            //         currentTokenDistribution += _fundDistributions[i].distributionTokens.amount;
            //     }
            // }
        }
        (uint256 minRaise, uint256 maxRaise, uint256 currentRaised) = IFund(_funds[fundID]).getRaisedInfo();
        // think about tax
        if (currentRaised - currentTokenDistribution < amount) {
            return false;
        }
        return true;
    }
    
    function getClaimableDistributionAmount(bytes32 fundID, address investor) external view returns(uint256 currentTokenDistribution){
        currentTokenDistribution = _getClaimableDistributionAmount(fundID, investor);
    }



    function _getClaimableDistributionAmount(bytes32 fundID, address investor) internal view returns(uint256 currentTokenDistribution){
        // // calculate share
        uint256 sharePercentage = IFund(_funds[fundID]).getSharePercentage(investor);

        for(uint256 i=0;i <_fundDistributions[fundID].length; i++) {
            if (_distributionClaimed[_fundDistributions[fundID][i].distributionID][investor] == 0){
                currentTokenDistribution += (_fundDistributions[fundID][i].amount * sharePercentage / 1e18);
            }
        }
    }


    
    function claimDistribution(bytes32 fundID) external {

        address claimer = msg.sender;
        uint256 currentTokenDistribution = _getClaimableDistributionAmount(fundID, claimer);
        if (currentTokenDistribution > 0) {
                
            // if (_distributionClaimed[distributionID][msg.sender] > 0) {
            //     revert DistributionAlreadyClaimedBefore(distributionID);
            // }
            address distributeToken = address(0);

            for(uint256 i=0;i <_fundDistributions[fundID].length; i++) {
                if (_distributionClaimed[_fundDistributions[fundID][i].distributionID][claimer] == 0){
                    _distributionClaimed[_fundDistributions[fundID][i].distributionID][claimer] = block.timestamp;

                    // now we have just one token, so it works now
                    distributeToken = _fundDistributions[fundID][i].token;
                }
            }

            IFund(_funds[fundID]).distribute(claimer, distributeToken, currentTokenDistribution);

        }
        
    }

    function getCreatedFunds() external view returns(bytes32[] memory) {
        return _fundList.values();
    }



    /// @inheritdoc IFundManager
    function createFund(NewFundInfo memory fundInfo)
        external
        override
        returns (address ucvAddress)
    {
        // authrized
        bytes32 fundID = _newID();
        // valid fundManager & riskManager have been set in the InvestmentCommittee
        bytes memory initData = abi.encode(address(this), fundID, fundInfo);

        address fundAddress = _deployByFactoryKey(FactoryKeyTypeID.UCV_TYPE_ID, fundInfo.fundDeployKey, initData);

        _funds[fundID] = fundAddress;
        _fundList.add(fundID);

        // address fundAddress = address(0);

        emit FundCreated(
            _dao,
            fundID,
            fundAddress,
            fundInfo.fundName,
            fundInfo.fundDescription,
            block.timestamp,
            msg.sender,
            fundInfo
        );
    }

    /// @inheritdoc IFundManager
    function getLaunchStatus(bytes32 fundID)
        external
        override
        view
        returns (uint256 status)
    {
        status = IFund(_funds[fundID]).getLaunchStatus();
    }

    /// @inheritdoc IFundManager
    function launchFund(bytes32 fundID) external override {
        // authrized
        IFund(_funds[fundID]).launch();
        // emit FundLaunched();
    }

    /// @inheritdoc IFundManager
    function startFund(bytes32 fundID) external override {
        // authrized
        IFund(_funds[fundID]).startFund();
        address treasuryUCV = IDAO(_dao).getUCV();
        IFund(_funds[fundID]).transferFixedFeeToUCV(treasuryUCV);

    }

    /// @inheritdoc IFundManager
    function getFundStatus(bytes32 fundID)
        external
        override
        returns (uint256 status)
    {
        status = IFund(_funds[fundID]).getFundStatus();
    }

    /// @inheritdoc IFundManager
    function getShareOfFund(bytes32 fundID)
        external
        view
        override
        returns (uint256 share)
    {
        share = IFund(_funds[fundID]).getShare(msg.sender);
    }


    function getFundOperationTime(bytes32 fundID) external view override returns(uint256, uint256) {
        return IFund(_funds[fundID]).getFundTime();
    }

    function tallyUpFund(bytes32 fundID) external override {
        IFund(_funds[fundID]).tallyUp();
    }


    /// @inheritdoc IFundManager
    function claimFundShare(bytes32 fundID) external override {
        // MAKE SURE FundStatus = 2 || 3 || 9
        
        uint256 status = IFund(_funds[fundID]).getFundStatus();
        if (status == 2  || status == 3 || status == 9) {
            console.log("address:", _funds[fundID]);
            IFund(_funds[fundID]).claimShare(msg.sender);

        } else {

            revert CannotClaimShareNow(status);
        }

    }

    /// @inheritdoc IFundManager
    function withdrawPrincipal(bytes32 fundID) external override {
        // MAKE SURE FundStatus = 1 failed

        uint256 status = IFund(_funds[fundID]).getFundStatus();
        if (status == 1) {
            IFund(_funds[fundID]).withdrawPrincipal(msg.sender);
        } else {

            revert TheFundCanNotWithdrawPrincipalNow();
        }
    }

    /// @inheritdoc IFundManager
    function claimPrincipalAndProfit(bytes32 fundID) external override {
        // MAKE SURE FundStatus = 9
        uint256 status = IFund(_funds[fundID]).getFundStatus();
        if (status == 9) {
            IFund(_funds[fundID]).claimPrincipalAndProfit(msg.sender);
        } else {
            revert TheFundNeedToTallyUp();
        }

    }

    /// @inheritdoc IFundManager
    function getFundLaunchTimeInfo(bytes32 fundID)
        external
        view
        override
        returns (uint256, uint256)
    {
        return IFund(_funds[fundID]).getLaunchTime();
    }



    /// @inheritdoc IFundManager
    function triggerFundLaunchStatus(bytes32 fundID)
        external
        override
    {
        IFund(_funds[fundID]).triggerLaunchStatus();
    }

    function getFund(bytes32 fundID)
        external
        view
        override
        returns (address fundAddress)
    {
        fundAddress = _funds[fundID];
    }

    uint256 private _seed = 0;
    
    function _newID() private returns (bytes32 fundID) {
        _seed++;
        fundID = keccak256(abi.encodePacked(_seed, address(this)));
    }


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

        // bool _success = true;
        if (_success) {

            // revert SucceedButRevert(_returnedBytes);
            
            deployedAddress = turnBytesToAddress(_returnedBytes);
        } else {
            revert DeployFailuer(contractKey);
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
