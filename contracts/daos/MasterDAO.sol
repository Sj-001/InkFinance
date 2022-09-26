//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseDAO.sol";
import "hardhat/console.sol";

contract MasterDAO is BaseDAO {
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;

    function newBoardProposal(
        NewProposalInfo calldata proposal,
        bool commit,
        bytes calldata data
    ) public returns (bytes32 proposalID) {
        proposalID = _newProposal(proposal, commit, data);

        // 0x 全0 DAO 内部Offchain
        // 0x 全FFF 任意执行，
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            DEFAULT_FLOW_ID
        ];

        bytes32 firstStep = steps[_SENTINEL_ID].nextStep;
        if (firstStep == bytes32(0x0)) {
            revert SystemError();
        }

        // bytes32[] memory proposer_duties = ICommittee(
        //     steps[firstStep].committee
        // ).getCommitteeDuties();

        // if (!_hasDuty(_msgSender(), proposer_duties[0])) {
        //     revert NotAllowedToOperate();
        // }

        // require(_msgSender() == steps[firstStep].committee, "no right");

        // IProposalRegistry proposalRegistry = _getProposalRegistry();
        // proposalID = proposalRegistry.newProposal(proposal, data);

        // initial process of the progress
        ProposalProgress storage info = _proposalInfo[proposalID];
        info.proposalID = proposalID;

        // decicde next step and which commit is handle the process
        info.nextCommittee.step = firstStep;
        info.nextCommittee.committee = steps[firstStep].committee;

        _decideProposal(proposalID, info.nextCommittee.committee, true);
    }

    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external override {
        console.log("call from", msg.sender);

        _decideProposal(proposalID, msg.sender, true);
    }

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}
}
