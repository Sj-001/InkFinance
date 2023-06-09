//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";
import "../interfaces/IAgentHandler.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IFundManager.sol";
import "../libraries/defined/DutyID.sol";

import "hardhat/console.sol";

contract InvestmentCommittee is BaseCommittee {
    struct InitData {
        address[] members;
        bytes baseInitData;
    }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _init(dao_, config_, data_);
        // init fund manager here
        console.log("Investment Committee init called");
        // _fundManager = address(0);
        return callbackEvent;
    }

    /// @inheritdoc ICommittee
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) external override returns (bytes32 proposalID) {}

    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {}

    /// @inheritdoc IVoteHandler
    function allowToVote(VoteIdentity calldata, address)
        external
        pure
        override
        returns (bool)
    {
        // reach minimal & fund raise not finished yet
        return false;
    }

    /// @inheritdoc ICommittee
    function tallyVotes(VoteIdentity calldata, bytes memory)
        external
        pure
        override
    {
        // make sure reach minimal purchase
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
