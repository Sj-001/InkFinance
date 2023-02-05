//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Each fund is an extension of UCV
interface IFund {

    /// @dev launch the fund (Only FundManager could execute)
    function launch() external;

    /// @dev manually update launch status
    function triggerLaunchStatus() external;

    /// @dev when the fund raised enough tokens, the fund admin could start fund and the fund manager
    /// could start to using raised fund to invest
    /// meanwhile generate share tokens for claim
    /// Only FunderManager could run this
    function startFund() external;

    /// @dev get launch status
    /// @return status 0=not launched yet 1=launching 2=launch finished(time is over)
    function getLaunchStatus() external view returns (uint256 status);

    /// @dev purchase the fund share
    /// have to meet requirement
    /// 1. still launching
    /// 2. raised fund + amount less than max raise
    function purchaseShare(uint256 amount) external payable;

    /// @dev get fund's status
    /// @return status 
    /// 0=not start yet(need to start fund) 
    /// 1=failed(launch status is finished and raised fund not reach min raise tokens) 
    /// 2=could start
    /// 3=started
    /// 9=finished(could claim the principal & profit of investment)
    function getFundStatus() external returns (uint256 status);

    /// @dev calculate the profit and transfer to the treasury
    function tallyUp() external;

    /// @dev get the fund raised progress
    function getRaisedInfo() external returns (uint256 minRaise, uint256 maxRaise, uint256 currentRaised);


    /// @dev return how many purchased no matter the user withdraw the principal
    function getOriginalInvested(address owner) external view returns (uint256 amount);


    /// @dev fund manager ask to pay for the fixed fee
    function transferFixedFeeToUCV(address treasuryUCV) external;

    function getLaunchTime() external view returns(uint256 start, uint256 end);

    function getFundTime() external view returns(uint256 start, uint256 end);


    // function claimShare(address owner) external;

    /// @dev when launching is finished and can't raise enough token,
    /// the user could withdraw their principal
    // function withdrawPrincipal(address owner) external;


    /// @dev after Admin click tallyUp the fund and the profit is ready,
    /// then user could claim the principal and profit
    // function claimPrincipalAndProfit(address owner) external;

    // function getOwnerPercentage(address owner) external view returns(uint256 perc);

    /// @dev get how may fund token will get of the owner
    // function getShare(address owner) external view returns (uint256 amount);

    function distribute(address owner, address token, uint256 amount) external;


    function frozen(uint256 amount) external;
    

    function hasRoleSetting(uint256 roleType) external view returns (bool has);


    function isRoleAuthorized(uint256 roleType, address user) external view returns (bool authroized);

    function claimCertificate(address investor) external;
    function claimInvestment(address investor) external;

    function getClaimableInvestment(address investor) external view returns(uint256 amount);
    function getClaimableCertificate(address investor) external view returns(uint256 amount);


    function calculateClaimableAmount(address investor, uint256 total) external view returns(uint256 amount);
    // function test() external view;
}
