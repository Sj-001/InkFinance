//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IProposalHandler.sol";
import "../bases/BaseCommittee.sol";
import "hardhat/console.sol";

contract ThePublic is BaseCommittee {
    using LVoteIdentityHelper for VoteIdentity;

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

    /// @inheritdoc ICommittee
    function decideProposal(VoteIdentity calldata identity, bytes memory data)
        public
        override
    {
        console.log("parent dao:", getParentDAO());
        // @todo verify duty
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
        // @todo verify if it's expired.
        bool passOrNot = _calculateVoteResults(identity);
        console.log("pass or not", passOrNot);
        
        proposalHandler.decideProposal(identity.proposalID, passOrNot, data);
    }

    function _calculateVoteResults(VoteIdentity calldata identity)
        internal
        returns (bool _passedOrNot)
    {
        // require(_getVoteExpiration(proposal) < block.timestamp, "vote not end");
        // require(_checkProposalStatus(proposal, identity), "no right proposal");
        VoteInfo storage voteInfo = _voteInfos[identity._getIdentityID()];

        bool agree;

        if (
            voteInfo.totalVotes >= minEffectiveVotes &&
            voteInfo.agreeVoterNum + voteInfo.denyVoterNum >=
            minEffectiveWallets
        ) {
            agree =
                (voteInfo.agreeVotes * 1e18) / (voteInfo.totalVotes) >
                minAgreeRatio;
        } else {
            agree = false;
        }

        if (agree) {
            voteInfo.status = VoteStatus.AGREE;
        } else {
            voteInfo.status = VoteStatus.DENY;
        }
        _passedOrNot = agree;
        // IDAO(proposal.dao).decideProposal(proposal.proposalID, agree, "");
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
