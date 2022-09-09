//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";

contract TheBoard is BaseCommittee {
    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}

    /// variables

    /// @notice when create proposal, how many staked tokens need to be locked.
    // uint256 public makeProposalLockVotes;

    // struct InitData {
    //     uint256 makeProposalLockVotes;
    //     bytes baseInitData;
    // }

    // function init(
    //     address admin,
    //     address addrRegistry,
    //     bytes calldata data
    // ) external override initializer returns (bytes memory callbackEvent) {

    //     InitData memory initData = abi.decode(data, (InitData));
    //     makeProposalLockVotes = initData.makeProposalLockVotes;

    //     _init(admin, addrRegistry, initData.baseInitData);
    //     _memberSetting(admin, 1);

    //     return callbackEvent;
    // }
}
