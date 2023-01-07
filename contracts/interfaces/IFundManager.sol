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
    /// @return status 0=not launched yet 1=launched 2=launch finished(time is over)
    function getLaunchStatus(bytes32 fundID) external returns (uint256 status);

    /// @dev after fund created, the fund manager could launch fund
    function launchFund(bytes32 fundID) external;

    /// @dev when the fund raised enough tokens, the fund admin could start fund and the fund manager
    /// could start to using raised fund to invest
    /// Only FunderManager could run this
    function startFund(bytes32 fundID) external;

    /// @dev get fund's status
    /// @return status 0=not start yet(need to start fund) 1=failed(launch status is finished and raised fund not reach min raise tokens) 2=started 3=finished(could claim the principal & profit of investment)
    function getFundStatus(bytes32 fundID) external returns (uint256 status);

    /// @dev get how many share token could claim
    function geFundShare(bytes32 fundID) external view returns (uint256 share);

    /// @dev claim share token
    function claimFundShare(bytes32 fundID) external;

    /// @dev withdraw principal, when launch status is over and fund status is failed
    function withdrawPrincipal(bytes32 fundID) external;

    /// @dev claim principal and profit, require fund share token to prove the share
    function claimPrincipalAndProfit(bytes32 fundID) external;
    
}
