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
        if (
            !_hasDutyToOperate(
                DutyID.OPERATOR,
                _msgSender()
            )
        ) {
            revert YouDoNotHaveDutyToOperate();
        }

        // verify duty
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());
        proposalID = proposalHandler.newProposal(proposal, commit, data);

        bytes32 flowID = IAgentHandler(getParentDAO()).getAgentFlowID(
            proposal.agents[0]
        );

        IProposalHandler.CommitteeInfo[] memory infos = IDAO(getParentDAO())
            .getFlowSteps(flowID);
        // valid committee
        // require(stepInfo.committee == address(this), "sys err");
        VoteIdentity memory identity;
        identity.proposalID = proposalID;
        identity.step = infos[0].step;

        // identity.
        // _vote(identity, true, 1, false, "", "");

        // //// deal vote process info
        // VoteInfo storage voteInfo = _voteInfos[voteID];
        // voteInfo.status = VoteStatus.AGREE;
        // voteInfo.identity.proposalID = proposalID;
        // voteInfo.identity.step = stepInfo.step;
        // // just one votes
        // voteInfo.totalVotes = 1;
        // voteInfo.agreeVotes = 1;
        // voteInfo.agreeVoterNum = 1;

        // //// deal vote detail info
        // //default agree
        // mapping(address => PersonVoteDetail)
        //     storage detail = _proposalVoteDetail[voteID][true];
        // PersonVoteDetail storage sentinel = detail[LChainLink.SENTINEL_ADDR];
        // sentinel.link._init();
        // PersonVoteDetail storage voteDetail = detail[_msgSender()];

        // voteDetail.link._addItemLink(
        //     sentinel.link,
        //     detail[sentinel.link._getNextAddr()].link,
        //     _msgSender()
        // );
        // voteDetail.voteCount = 1;
        // console.log("making proposal");
        // IDAO(getParentDAO()).tallyVotes
        console.log("I'm treasury committee:", address(this));

        bool passOrNot = true;
        proposalHandler.decideProposal(identity.proposalID, passOrNot, data);
    }

    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {
        // const SIGNER_DUTYID = "0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f";

        if (
            !_hasDutyToOperate(
                DutyID.SIGNER,
                _msgSender()
            )
        ) {
            revert YouDoNotHaveDutyToOperate();
        }

        _vote(identity, agree, count, true, feedback, data);
    }

    /// @inheritdoc ICommittee
    function tallyVotes(VoteIdentity calldata, bytes memory) external override {
        //
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
