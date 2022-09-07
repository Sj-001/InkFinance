//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./IProposalInfo.sol";
import "./IProposalRegistryInfo.sol";

/// @title IProposalRegistry
/// @author InkTech <tech-support@inkfinance.xyz>
interface IProposalRegistry is IERC165, IProposalInfo, IProposalRegistryInfo {
    //////////////////// event

    // proposal
    event ENewProposal(
        address indexed dao,
        bytes32 indexed proposalID,
        bytes[] metadata,
        bytes[] kvData
    );

    event EProposalAppend(
        address indexed dao,
        bytes32 indexed proposalID,
        bytes[] kvData
    );

    event EProposalDecide(
        address indexed dao,
        bytes32 indexed proposalID,
        bool indexed agree,
        bytes32 topicID
    );

    // topic
    event ETopicCreate(
        address indexed dao,
        bytes32 indexed topicID,
        bytes32 indexed proposalID
    );

    event ETopicFix(
        address indexed dao,
        bytes32 indexed topicID,
        bytes32 indexed proposalID
    );

    //////////////////// exec
    function newProposal(
        ProposalApplyInfo calldata proposal,
        bytes calldata data
    ) external returns (bytes32 proposalID);

    // used to append new kvData(can convert old same key)
    function changeProposal(
        bytes32 proposalID,
        bytes[] calldata kvData,
        bytes calldata data
    ) external;

    // if agree, apply the proposal kvdata to topic.
    function decideProposal(
        bytes32 proposalID,
        bool agree,
        bytes calldata data
    ) external;
}
