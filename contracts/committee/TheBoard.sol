//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";
import "../interfaces/IProposalHandler.sol";

import "hardhat/console.sol";

/// @notice the board committee has the highest priority of the DAO
contract TheBoard is BaseCommittee {
    /// @notice when create proposal, how many staked tokens need to be locked.
    // uint256 public makeProposalLockVotes;

    // struct InitData {
    //     uint256 makeProposalLockVotes;
    //     bytes baseInitData;
    // }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        super.init(config_);
        _parentDAO = dao_;

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
    ) external override returns (bytes32 proposalID) {
        console.log("parent dao:", getParentDAO());
        // verify duty
        // IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
        // proposalHandler.newProposal(proposal, commit, data);

        console.log("making proposal");
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
