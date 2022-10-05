//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IProposalHandler.sol";
import "../bases/BaseCommittee.sol";
import "hardhat/console.sol";

contract ThePublic is BaseCommittee {
    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        console.log("init in the Public:", dao_);
        _init(dao_, config_, data_);
        return callbackEvent;
    }

    /// @inheritdoc ICommittee
    function newProposal(
        NewProposalInfo calldata,
        bool,
        bytes calldata
    ) external pure override returns (bytes32) {
        revert ThisCommitteeCannotMakeProposal();
    }

    /// @inheritdoc IVoteHandler
    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {
        console.log(
            "public voting ------------------------------------------------------------------------------------ "
        );

        // it's public everyone has duty to vote
        _vote(identity, agree, count, true, feedback, data);
    }

    /// @inheritdoc ICommittee
    function tallyVotes(VoteIdentity calldata identity, bytes memory data)
        public
        override
    {
        _tallyVotes(identity, data);
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
