//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFundInfo {

    /// @dev when create a fund, fund init info structure should be orgnized and submit to FundManager
    struct NewFundInfo {
        bytes32 fundDeployKey;
        string fundName;
        string fundDescription;
        address fundToken;
        uint256 minRaise;
        uint256 maxRaise;
        uint256 raisedPeriod;
        uint256 durationOfFund;
        uint256 allowIntermittentDistributions;
        uint256 allowFundTokenized;
        string tokenName;
        // uint256 tokenAmount;
        uint256 allowExchange;
        uint256 auditPeriod;
        uint256 investmentDomain;
        uint256 investmentType;
        uint256 maxSingleExposure;
        uint256 minNumberOfHoldings;
        uint256 maxNavDowndraftFromPeak;
        uint256 maxNavLoss;
        uint256 requireClientBiometricIdentity;
        uint256 requireClientLegalIdentity;
        uint256 fixedFee;
        uint256 fixedFeeShouldGoToTreasury;
        uint256 performanceFee;
        uint256 performanceFeeShouldGoToTreasury;
        address[] fundManagers;
        address[] riskManagers;
    }


    struct DistributionInfo{
        address token;
        uint256 amount;
    }

    struct FundDistribution {
        bytes32 distributionID;
        // DistributionInfo[] distributionTokens;
        address token;
        uint256 amount;
    }

    event DistributionCreated(
        bytes32 fundID,
        address fundAddress,
        address creator,
        uint256 createTime,
        bytes32 distributionID,
        string distributionRemark,
        address distributionToken,
        uint256 distributionAmount
    );
    // DistributionInfo[] distributionTokens
    
    event DistributionClaimed(
        bytes32 fundID,
        address fundAddress,
        address claimer,
        uint256 claimTime,
        bytes32 lastDistributionID,
        address claimToken,
        uint256 claimAmount
    );
    

    event FundStart (
        bytes32 fundID,
        address fundAddress,
        uint256 startTime,
        uint256 endTime
    );


    event LaunchStart (
        bytes32 fundID,
        address fundAddress,
        uint256 startTime,
        uint256 endTime
    );


    event FundCreated(
        address daoAddres,
        bytes32 fundID,
        address fundAddress,
        string name,
        string description,
        uint256 createTime,
        address creator,
        NewFundInfo fundInfo
    );


    event FundPurchase(
        address daoAddres,
        bytes32 fundID,
        address fundAddress,
        address buyer,
        uint256 purchaseTime,
        uint256 purchaseAmount,
        uint256 totalPurchased
    );

    /// @dev when status changed this event will emit
    /// @param fundID the id of the fund
    /// @param statusType 1=launch status, 2=fund status
    /// @param previousStatus previous status
    /// @param currentStatus current status
    /// @param updateTime time 
    event FundStatusUpdated(bytes32 fundID, uint256 statusType, uint256 previousStatus, uint256 currentStatus, uint256 updateTime);

}
