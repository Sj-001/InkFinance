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
        uint256 tokenAmount;
        uint256 allowExchange;
        uint256 auditPeriod;
        string investmentDomain;
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
    }

    /// @dev basic fund info
    /// @param funds fund ucv contract address
    struct FundInfo {
        bytes32 fundID;
        address funds;
        address fundToken;
        uint256 minRaise;
        uint256 maxRaise;
        uint256 raisingPeriod;
        uint256 durationOfFund;
        uint256 startRaisingDate;
        uint256 totalRaised;
    }

    event FundCreated(
        bytes32 fundID,
        address fundAddress,
        string name,
        string description,
        NewFundInfo fundInfo
    );

    event FundLaunched(bytes32 fundID, uint256 launchTime);
}
