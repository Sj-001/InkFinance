//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/ICommittee.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IProposalHandler.sol";
import "../interfaces/IDutyControl.sol";
import "../interfaces/IProcessHandler.sol";

import "../libraries/LVoteIdentityHelper.sol";
import "../libraries/LEnumerableMetadata.sol";
import "../libraries/LChainLink.sol";

import "./BaseVerify.sol";
import "hardhat/console.sol";

error NotAllowToOperate();
error CannotTallyVote();
error CannotOperateBecauseOfDutyID(bytes32 dutyID);
error VoteTimeExpired();

abstract contract BaseCommittee is IDeploy, ICommittee, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    using LVoteIdentityHelper for VoteIdentity;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using LChainLink for LChainLink.Link;

    /// structs ////////////////////////////////////////////////////////////////////////////////

    /// @dev key is voter's address
    struct PersonVoteDetail {
        uint256 voteCount;
        LChainLink.Link link;
    }

    string private _committeeName;
    string private _describe;
    bytes[] private _mds;

    /// @dev all committee's duties stored here
    EnumerableSet.Bytes32Set private _committeeDuties;
    // variables
    /// @dev belong to which DAO
    address internal _parentDAO;

    // keccak256(proposalID, step) => vote info
    mapping(bytes32 => VoteInfo) internal _voteInfos;

    // vote identity => agree/deny = > voter addr => vote detail
    mapping(bytes32 => mapping(bool => mapping(address => PersonVoteDetail)))
        internal _proposalVoteDetail;

    function _init(
        address dao_,
        address config_,
        bytes calldata data
    ) internal {
        super.init(config_);
        _parentDAO = dao_;

        (string memory name, bytes memory duties) = abi.decode(
            data,
            (string, bytes)
        );

        _committeeName = name;

        bytes32[] memory dutyArray = abi.decode(duties, (bytes32[]));
        for (uint256 i = 0; i < dutyArray.length; i++) {
            _committeeDuties.add(dutyArray[i]);
        }
    }

    function getParentDAO() internal view returns (address parentDAO) {
        parentDAO = _parentDAO;
    }

    /// @inheritdoc ICommittee
    function getCommitteeDuties()
        external
        view
        override
        returns (bytes32[] memory duties)
    {
        duties = _committeeDuties.values();
    }

    /// @inheritdoc IVoteHandler
    function getVoteDetailByAccount(
        VoteIdentity calldata identity,
        address account
    ) external view override returns (uint256 agreeVotes, uint256 denyVotes) {
        return _getProposalAccountDetail(identity._getIdentityID(), account);
    }

    /// @inheritdoc IVoteHandler
    function getVoteSummary(VoteIdentity memory identity)
        public
        view
        virtual
        override
        returns (VoteInfo memory result)
    {
        return _voteInfos[identity._getIdentityID()];
    }

    /// @inheritdoc ICommittee
    function allowOperate(VoteIdentity memory identity, address user)
        public
        view
        virtual
        override
        returns (bool allowToOperate)
    {
        ProposalSummary memory proposal = IProposalHandler(getParentDAO())
            .getProposalSummary(identity.proposalID);

        return _checkAllowOperate(proposal, identity, user);
    }

    function _hasDutyToOperate(bytes32 dutyID, address operator)
        internal
        view
        returns (bool hasDutyToOperate)
    {
        hasDutyToOperate = IDutyControl(getParentDAO()).hasDuty(
            operator,
            dutyID
        );
    }

    /// @dev by default, vote require pledge
    function _vote(
        VoteIdentity memory identity,
        bool agree,
        uint256 count,
        bool requestPledge,
        string memory feedback,
        bytes memory data
    ) internal {
        if (!allowOperate(identity, _msgSender())) {
            revert NotAllowToOperate();
        }

        bytes32 voteID = identity._getIdentityID();
        VoteInfo storage voteInfo = _voteInfos[voteID];
        if (voteInfo.identity._getIdentityID() != voteID) {
            voteInfo.identity = identity;
        }

        mapping(address => PersonVoteDetail)
            storage detail = _proposalVoteDetail[voteID][agree];

        PersonVoteDetail storage sentinel = detail[LChainLink.SENTINEL_ADDR];
        if (sentinel.link._isEmpty()) {
            sentinel.link._init();
        }

        uint256 addAccount;
        PersonVoteDetail storage voteDetail = detail[_msgSender()];
        if (voteDetail.link._isEmpty()) {
            voteDetail.link._addItemLink(
                sentinel.link,
                detail[sentinel.link._getNextAddr()].link,
                _msgSender()
            );
            addAccount = 1;
        }

        require(
            _proposalVoteDetail[voteID][!agree][_msgSender()].voteCount == 0,
            "Cannot vote in reverse"
        );
        voteDetail.voteCount = voteDetail.voteCount + count;

        // if someone agree, can't deny anymore
        if (agree) {
            voteInfo.agreeVotes = voteInfo.agreeVotes + count;
            if (addAccount > 0) {
                voteInfo.agreeVoterNum = voteInfo.agreeVoterNum + addAccount;
            }
        } else {
            voteInfo.denyVotes = voteInfo.denyVotes + count;
            if (addAccount > 0) {
                voteInfo.denyVoterNum = voteInfo.denyVoterNum + addAccount;
            }
        }
        voteInfo.totalVotes = voteInfo.denyVotes + voteInfo.agreeVotes;
        // if (requestPledge)
        // _requestGovernancePledging(proposal, voteID, _msgSender(), count);
        emit Vote(voteID, _msgSender(), agree, count, feedback);
    }

    // /// @inheritdoc IVoteHandler
    // function vote(
    //     VoteIdentity calldata identity,
    //     bool agree,
    //     uint256 count,
    //     string calldata feedback,
    //     bytes calldata data
    // ) external override {
    //     _vote(identity, agree, count, true, feedback, data);
    // }

    /// @inheritdoc IVoteHandler
    function getVoteDetail(
        VoteIdentity calldata identity,
        bool agreeOrDisagreeOption,
        address startVoter,
        uint256 pageSize
    ) external view override returns (MemberVoteInfo[] memory voteDetails) {
        bytes32 voteID = identity._getIdentityID();

        mapping(address => PersonVoteDetail)
            storage detail = _proposalVoteDetail[voteID][agreeOrDisagreeOption];

        if (detail[LChainLink.SENTINEL_ADDR].link._isEmpty()) {
            return voteDetails;
        }

        voteDetails = new MemberVoteInfo[](pageSize);
        if (LChainLink._isEmpty(startVoter)) {
            startVoter = LChainLink.SENTINEL_ADDR;
        }

        uint256 idx = 0;
        address currentVoter = detail[startVoter].link._getNextAddr();

        while (idx < pageSize && !LChainLink._isEmpty(currentVoter)) {
            PersonVoteDetail storage voteDetail = detail[currentVoter];

            voteDetails[idx].voter = currentVoter;
            voteDetails[idx].count = voteDetail.voteCount;

            currentVoter = detail[currentVoter].link._getNextAddr();

            idx++;
        }

        assembly {
            mstore(voteDetails, idx)
        }

        return voteDetails;
    }

    function _checkAllowOperate(
        ProposalSummary memory proposal,
        VoteIdentity memory identity,
        address user
    ) internal view returns (bool) {
        if (!_checkProposalStatus(proposal, identity)) {
            console.log("status");
            return false;
        }

        if (!_hasRequiredVoteBadge(proposal, user)) {
            console.log("no badge");
            return false;
        }

        return true;
    }

    function _hasRequiredVoteBadge(
        ProposalSummary memory proposal,
        address user
    ) internal view returns (bool has) {
        return IDAO(_parentDAO).hasDAOBadges(user);
    }

    function _calculateVoteResults(
        VoteIdentity memory identity,
        bool ignoreBaseRule
    ) internal returns (bool _passedOrNot) {
        VoteInfo storage voteInfo = _voteInfos[identity._getIdentityID()];

        bool agree;
        console.log("voteInfo.agreeVoterNum", voteInfo.agreeVoterNum);
        if (voteInfo.agreeVoterNum > voteInfo.denyVoterNum) {
            agree = true;
        } else {
            agree = false;
        }

        console.log("agree?", agree);
        if (agree) {
            voteInfo.status = VoteStatus.AGREE;
        } else {
            voteInfo.status = VoteStatus.DENY;
        }
        _passedOrNot = agree;
    }

    function _calculateVoteResults(VoteIdentity memory identity)
        internal
        returns (bool _passedOrNot)
    {
        // require(_checkProposalStatus(proposal, identity), "no right proposal");
        (
            uint256 minAgreeRatio,
            uint256 minEffectiveVotes,
            uint256 minEffectiveWallets
        ) = IProposalHandler(getParentDAO()).getTallyVoteRules(
                identity.proposalID
            );

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

            console.log(
                "######",
                (voteInfo.agreeVotes * 1e18) / (voteInfo.totalVotes)
            );
            console.log("######", minAgreeRatio);
        } else {
            agree = false;
        }
        if (agree) {
            voteInfo.status = VoteStatus.AGREE;
        } else {
            voteInfo.status = VoteStatus.DENY;
        }
        _passedOrNot = agree;
    }

    function _tallyVotes(
        VoteIdentity calldata identity,
        bytes memory data,
        bool considerExpired
    ) internal {
        // @todo verify duty
        IProposalHandler proposalHandler = IProposalHandler(getParentDAO());

        if (considerExpired) {
            console.log(
                "consider expired:",
                IProcessHandler(getParentDAO()).getVoteExpirationTime(
                    identity.proposalID
                )
            );

            if (
                IProcessHandler(getParentDAO()).getVoteExpirationTime(
                    identity.proposalID
                ) > block.timestamp
            ) {
                revert CannotTallyVote();
            }
        }

        // @todo verify if it's expired.
        bool passOrNot = _calculateVoteResults(identity);

        VoteInfo storage voteInfo = _voteInfos[identity._getIdentityID()];
        if (passOrNot) {
            voteInfo.status = VoteStatus.AGREE;
        } else {
            voteInfo.status = VoteStatus.DENY;
        }
        console.log("tally vote result", passOrNot);
        proposalHandler.decideProposal(identity.proposalID, passOrNot, data);
    }

    function _getProposalAccountDetail(bytes32 voteID, address account)
        internal
        view
        returns (uint256 agree, uint256 deny)
    {
        return (
            _proposalVoteDetail[voteID][true][account].voteCount,
            _proposalVoteDetail[voteID][false][account].voteCount
        );
    }

    function _checkProposalStatus(
        ProposalSummary memory proposal,
        VoteIdentity memory identity
    ) internal view returns (bool) {
        if (proposal.status != IProposalInfo.ProposalStatus.PENDING) {
            return false;
        }

        (address committee, ) = IProcessHandler(_parentDAO)
            .getVoteCommitteeInfo(proposal.proposalID);
        console.log("supposed committee is: ", committee);
        console.log("now committee is: ", address(this));
        if (committee != address(this)) {
            console.log("wrong step ################################# ");
            return false;
        }

        // IDAO.ProposalCommitteeInfo memory nextInfo = IDAO(proposal.dao)
        //     .getNextCommittee(proposal.proposalID);
        // if (
        //     nextInfo.step != identity.step ||
        //     nextInfo.committee != address(this)
        // ) {
        //     return false;，
        // }

        return true;
    }

    function _checkDeadline(ProposalSummary memory proposal)
        internal
        view
        returns (bool end)
    {
        return
            IProcessHandler(getParentDAO()).getVoteExpirationTime(
                proposal.proposalID
            ) < block.timestamp;
    }

    function _isDeadlineExpired(bytes32 proposalID)
        internal
        view
        returns (bool isExpired)
    {
        ProposalSummary memory proposal = IProposalHandler(getParentDAO())
            .getProposalSummary(proposalID);

        isExpired = _checkDeadline(proposal);
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
            interfaceId == type(ICommittee).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }
}
