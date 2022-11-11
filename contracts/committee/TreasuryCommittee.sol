//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";
import "../interfaces/IAgentHandler.sol";
import "../interfaces/IDAO.sol";
import "../libraries/defined/DutyID.sol";
import "hardhat/console.sol";

contract TreasuryCommittee is BaseCommittee {
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
        // InitData memory initData = abi.decode(data_, (InitData));
        // makeProposalLockVotes = initData.makeProposalLockVotes;
        // _init(admin, addrRegistry, initData.baseInitData);
        // _memberSetting(admin, 1);
        console.log("TreasuryCommittee. called initial ");
        return callbackEvent;
    }

    /// @inheritdoc ICommittee
    function newProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) external override returns (bytes32 proposalID) {
        if (!_hasDutyToOperate(DutyID.OPERATOR, _msgSender())) {
            revert YouDoNotHaveDutyToOperate();
        }

        // verify duty
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
        proposalID = proposalHandler.newProposal(proposal, commit, data);

        // bytes32 flowID = IAgentHandler(getParentDAO()).getAgentFlowID(
        //     proposal.agents[0]
        // );

        // IProposalHandler.CommitteeInfo[] memory infos = IDAO(getParentDAO())
        //     .getFlowSteps(flowID);
        // // valid committee
        // // require(stepInfo.committee == address(this), "sys err");
        // VoteIdentity memory identity;
        // identity.proposalID = proposalID;

        // console.log("I'm treasury committee:", address(this));

        // bool passOrNot = true;
        // proposalHandler.decideProposal(identity.proposalID, passOrNot, data);
    }

    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {
        // const SIGNER_DUTYID = "0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f";

        if (!_hasDutyToOperate(DutyID.SIGNER, _msgSender())) {
            revert YouDoNotHaveDutyToOperate();
        }

        _vote(identity, agree, count, true, feedback, data);

        // if any signer disageee, the proposal will be denied.
        if (!agree) {
            bool passOrNot = false;
            IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
            proposalHandler.decideProposal(
                identity.proposalID,
                passOrNot,
                data
            );
        }
        //
        _tally(identity);
    }

    function _tally(VoteIdentity memory identity) internal {
        // verify
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());

        uint256 signerCount = _getSignerCount();

        VoteInfo memory voteInfo = getVoteSummary(identity);

        uint256 voteMembers = voteInfo.agreeVoterNum;

        bool allSignerVoted = (signerCount == voteMembers);

        if (allSignerVoted) {
            console.log("tally votes ---------- passed !!!!! ");

            bool passOrNot = true;
            proposalHandler.decideProposal(identity.proposalID, passOrNot, "");
        }
    }

    function _getSignerCount() internal view returns (uint256 signers) {
        signers = IDutyControl(getParentDAO()).getDutyOwners(DutyID.SIGNER);
    }

    /// @inheritdoc IVoteHandler
    function allowToVote(VoteIdentity calldata, address)
        external
        pure
        override
        returns (bool)
    {
        return false;
    }

    /// @inheritdoc ICommittee
    function tallyVotes(VoteIdentity calldata, bytes memory)
        external
        pure
        override
    {
        revert NotAllowToOperate();
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
