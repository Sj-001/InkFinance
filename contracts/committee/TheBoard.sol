//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";
import "../interfaces/IProposalHandler.sol";
import "../libraries/defined/DutyID.sol";

import "hardhat/console.sol";

error OnlyAllowToVoteOne();

/// @notice the board committee has the highest priority of the DAO
contract TheBoard is BaseCommittee {
    /// @notice when create proposal, how many staked tokens need to be locked.
    uint256 private _minPledgeRequired;

    struct InitData {
        uint256 minPledgeRequired;
        bytes tallyVoteRules;
        bytes baseInitData;
    }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
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
    ) external override returns (bytes32 proposalID) {
        // valid have dutyID to create the proposal
        if (!_hasDutyToOperate(DutyID.PROPOSER, _msgSender())) {
            revert YouDoNotHaveDutyToOperate();
        }

        // valid the right step
        // valid the status of the proposal
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
        proposalID = proposalHandler.newProposal(proposal, commit, data);
    }

    /// @inheritdoc IVoteHandler
    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {
        // check duty
        if (!_hasDutyToOperate(DutyID.VOTER, _msgSender())) {
            revert YouDoNotHaveDutyToOperate();
        }

        if (count > 1) {
            revert OnlyAllowToVoteOne();
        }

        _vote(identity, agree, count, true, feedback, data);
    }

    /// @inheritdoc IVoteHandler
    function allowToVote(VoteIdentity calldata identity, address voteUser)
        external
        view
        override
        returns (bool)
    {
        if (!_hasDutyToOperate(DutyID.VOTER, voteUser)) {
            return false;
        }

        return allowOperate(identity, voteUser);
    }


    /**
        @todo 
    
    
     */

    /// @inheritdoc ICommittee
    function tallyVotes(VoteIdentity calldata identity, bytes memory data)
        external
        override
    {
        if (!_hasDutyToOperate(DutyID.PROPOSER, _msgSender())) {
            revert YouDoNotHaveDutyToOperate();
        }
        _tallyVotes(identity, data, false);
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
