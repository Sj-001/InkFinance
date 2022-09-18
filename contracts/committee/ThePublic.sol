//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";
import "hardhat/console.sol";

contract ThePublic is BaseCommittee {
    uint256 public minAgreeRatio;
    uint256 public minEffectiveVotes;
    uint256 public minEffectiveWallets;

    struct InitData {
        uint256 minAgreeRatio;
        uint256 minEffectiveVotes;
        uint256 minEffectiveWallets;
        bytes baseInitData;
    }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        console.log("init in the Public:", dao_);
        _init(dao_, config_, data_);
        // InitData memory initData = abi.decode(data_, (InitData));
        // makeProposalLockVotes = initData.makeProposalLockVotes;

        // _init(admin, addrRegistry, initData.baseInitData);
        // _memberSetting(admin, 1);
        return callbackEvent;
    }

    /// @inheritdoc ICommittee
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) external pure override returns (bytes32) {
        revert ThisCommitteeCannotMakeProposal();
    }

    /// @inheritdoc IDeploy
    function getTypeID() external pure override returns (bytes32 typeID) {
        typeID = 0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;
    }

    /// @inheritdoc IDeploy
    function getVersion() external pure override returns (uint256 version) {
        version = 1;
    }
}
