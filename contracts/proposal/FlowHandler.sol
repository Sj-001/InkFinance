//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDeploy.sol";
import "../interfaces/IProcessHandler.sol";

import "../bases/BaseVerify.sol";

import "../utils/BytesUtils.sol";
import "../libraries/defined/DutyID.sol";
import "../libraries/defined/TypeID.sol";

import "hardhat/console.sol";

contract FlowHandler /* is IProcessHandler, IDeploy, BaseVerify */ {

    /*
    using Address for address;
    using BytesUtils for bytes;

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;


    /// @notice store the connection between different committee in a flow
    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
    }

    // variables ////////////////////////////////////////////////////////////////////////
    /// @notice limit the vote flow steps at most 10 steps
    uint256 public constant MAX_STEP_NUM = 10;

    
    /// @dev stored proposal
    /// proposalID=>ProposalProgress
    mapping(bytes32 => ProposalProgress) internal _proposalInfo;


    address private _dao;

    /// @inheritdoc IDeploy
    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        // super.init(config_);

        _dao = dao_;
        return callbackEvent;
    }

    /// @inheritdoc IProcessHandler
    function getVoteExpirationTime(bytes32 proposalID)
        external
        view override
        returns (uint256 expiration) {
        (, bytes memory data) = IProposalHandler(_proposalHandlerAddress)
            .getProposalMetadata(proposalID, EXPIRATION_KEY);

        ProposalProgress storage info = _proposalInfo[proposalID];
        uint256 lastTime = info.lastOperationTimestamp;

        if (data.length != 0) {
            expiration = abi.decode(data, (uint256));
        } else {
            return uint256(int256(-1));
        }

        return lastTime + expiration;
    }


    function getNextVoteCommitteeInfo(bytes32 proposalID)
        external
        view
        returns (CommitteeInfo memory committeeInfo)
    {
        ProposalProgress storage info = _proposalInfo[proposalID];
        committeeInfo = info.nextCommittee;
    }

    /// @dev verify if the committee is the next committee
    function _isNextCommittee(bytes32 proposalID, address committee)
        internal
        view
        returns (bool)
    {
        address nextCommittee = _proposalInfo[proposalID]
            .nextCommittee
            .committee;
        console.log("next committee:", nextCommittee);

        if (nextCommittee == address(0x0)) {
            return false;
        }

        return nextCommittee == committee;
    }


    function _decideProposal(
        bytes32 proposalID,
        address committee,
        bool agree,
        bytes memory data
    ) internal {
        ProposalProgress storage info = _proposalInfo[proposalID];
        require(info.proposalID == proposalID, "proposal err");
        // why need to verify the next committee...
        // require(_isNextCommittee (proposalID, committee), "committee err");

        _appendFinishStep(info);
        _setNextStep(info, !agree);

        if (info.nextCommittee.committee == address(0x0)) {
            IProposalHandler(_proposalHandlerAddress).decideProposal(
                info.proposalID,
                agree,
                ""
            );
            _execFinish(info, agree);
        }
    }


   function _execFinish(ProposalProgress storage info, bool agree) internal {
        require(info.nextCommittee.committee == address(0x0), "can't finish");
        // emit EDecideProposal(info.proposalID, agree);
        console.log("exec finished:", agree);

        if (agree == false) {
            emit ProposalDecide(
                address(this),
                info.proposalID,
                agree,
                bytes32(0x0),
                block.timestamp
            );
            return;
        }

        bytes32[] memory agents = info.agents;
        if (agree == true) {
            // execute agent
            for (uint256 i = 0; i < agents.length; i++) {
                if (
                    agents[i] !=
                    0x0000000000000000000000000000000000000000000000000000000000000000
                ) {
                    address agentAddress = _agents[agents[i]];

                    console.log("agentAddress", agentAddress);

                    IAgent(agentAddress).exec(info.proposalID);
                }
            }
        }

        emit ProposalDecide(
            address(this),
            info.proposalID,
            agree,
            IProposalHandler(_proposalHandlerAddress).getProposalTopic(
                info.proposalID
            ),
            block.timestamp
        );
    }

    function _setNextStep(ProposalProgress storage info, bool breakFlow)
        internal
    {

        if (!breakFlow) {
            bytes32 flowID = info.flowID;
            StepLinkInfo storage nowStep = _flowSteps[flowID][
                info.nextCommittee.step
            ];
            info.nextCommittee.step = nowStep.nextStep;
            info.nextCommittee.committee = _flowSteps[flowID][nowStep.nextStep]
                .committee;
        } else {
            info.nextCommittee.step = bytes32(0x0);
            info.nextCommittee.committee = address(0x0);
        }
        
    }

    function _appendFinishStep(ProposalProgress storage info) internal {
        CommitteeInfo storage committeeInfo = info.committees.push();
        committeeInfo.committee = info.nextCommittee.committee;
        committeeInfo.step = info.nextCommittee.step;
        info.lastOperationTimestamp = block.timestamp;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IProcessHandler).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}

    */
}
