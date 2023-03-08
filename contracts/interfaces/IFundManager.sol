//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IFundInfo.sol";

interface IFundManager is IFundInfo {
    /**
        @dev create a fund (UCV) for taking user's investment 
        every create fund proposal would create a independent UCV
    */
    function createFund(NewFundInfo memory fundInfo)
        external
        returns (address contractAddr);

    /// @dev get the fund contract address of the fund, each fund has their own fund ucv to collect assets.
    function getFund(bytes32 fundID) external returns (address fundAddres);

    /// @dev check the fund is launched or not
    /// @return status 0=not launched yet 1=launched 2=launch finished(time is over) 9=after tallyUp and finalized
    function getLaunchStatus(bytes32 fundID) external returns (uint256 status);

    /// @dev after fund created, the fund manager could launch fund
    function launchFund(bytes32 fundID) external;

    /// @dev when the fund raised enough tokens, the fund admin could start fund and the fund manager
    /// could start to using raised fund to invest
    /// Only FunderManager could run this
    function startFund(bytes32 fundID) external;

    /// @dev make the succeed fund ready claimed by the investors
    function tallyUpFund(bytes32 fundID) external;

    /// @dev get fund's status
    /// @return status 0=not start yet(need to start fund) 1=failed(launch status is finished and raised fund not reach min raise tokens) 2=started 3=finished(could claim the principal & profit of investment)
    function getFundStatus(bytes32 fundID) external returns (uint256 status);

    /// @dev claim share token
    // function claimFundShare(bytes32 fundID) external;

    /// @dev withdraw principal, when launch status is over and fund status is failed
    function withdrawPrincipal(bytes32 fundID) external;

    /// @dev claim principal and profit, require fund share token to prove the share
    function claimPrincipalAndProfit(bytes32 fundID) external;

    /// @dev get fund lauch start time & end time(if it's not launch yet, startTime = 0)
    function getFundLaunchTimeInfo(bytes32 fundID)
        external
        view
        returns (uint256 startTime, uint256 endTime);

    function getFundOperationTime(bytes32 fundID)
        external
        view
        returns (uint256 startTime, uint256 endTime);

    /// @dev if raise time is up, update launch status (fund status also)
    function triggerFundLaunchStatus(bytes32 fundID) external;

    /// @dev get originally how many token invested
    function getOriginalInvestment(bytes32 fundID, address owner)
        external
        view
        returns (uint256 amount);

    /// @dev get how many tokens could claim
    function getCurrentInvestment(bytes32 fundID, address owner)
        external
        view
        returns (uint256 amount);

    /// @dev get how many certificates could claim
    function getFundCertificate(bytes32 fundID, address owner)
        external
        view
        returns (uint256 amount);

    /// @dev check operator has role type setting during create the committee
    /// @param roleType 1=FundManager 2=RiskManager
    function isCommitteeOperator(uint256 roleType, address operator)
        external
        view
        returns (bool exist);

    /// @dev check operator has role type setting combine in the committee and during create the fund(the fund has higher priority)
    /// @param roleType 1=FundManager 2=RiskManager
    function isAuthorizedFundOperator(
        bytes32 fundID,
        uint256 roleType,
        address operator
    ) external view returns (bool authorized);

    function getFundDistributionAmount(bytes32 fundID)
        external
        view
        returns (uint256 amount);

    function claimFundCertificate(bytes32 fundID) external;

    function liquidateFund(bytes32 fundID) external;

    function getCreatedDistributes(bytes32 fundID)
        external
        view
        returns (FundDistribution[] memory);

    function allocateFundServiceFee(
        bytes32 fundID,
        address[] memory members,
        uint256[] memory fee,
        bytes memory data
    ) external;
}
