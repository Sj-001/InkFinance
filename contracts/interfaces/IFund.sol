//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Each fund is an extension of UCV
interface IFund {
    /// @dev launch the fund (Only FundManager could execute)
    function launch() external;

    /// @dev get launch status
    /// @return status 0=not launched yet 1=launched 2=launch finished(time is over)
    function getLaunchStatus() external view returns (uint256 status);

    /// @dev purchase the fund share
    /// have to meet requirement
    /// 1. still launching
    /// 2. raised fund + amount less than max raise
    function purchaseShare(uint256 amount) external;

    /// @dev get fund's status
    /// @return status 0=not start yet(need to start fund) 1=failed(launch status is finished and raised fund not reach min raise tokens) 2=started 3=finished(could claim the principal & profit of investment)
    function getFundStatus() external returns (uint256 status);

    /// @dev calculate the profit and transfer to the treasury
    /// meanwhile generate share tokens for claim
    function tallyUp() external;

    /// @dev get how may fund token will get of the owner
    function getShare(address owner) external returns (uint256 amount);
}
