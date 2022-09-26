//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/ICommittee.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IProposalHandler.sol";

import "../libraries/LVoteIdentityHelper.sol";
import "../libraries/LEnumerableMetadata.sol";
import "../libraries/LChainLink.sol";

import "./BaseVerify.sol";
import "hardhat/console.sol";

abstract contract BaseCommittee is IDeploy, ICommittee, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    using LVoteIdentityHelper for VoteIdentity;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using LChainLink for LChainLink.Link;

    /// structs ////////////////////////////////////////////////////////////////////////////////
    struct BaseCommitteeInitData {
        string name;
        string describe;
        bytes[] mds;
        address daoAddress;
    }

    // key is voter addr
    struct PersonVoteDetail {
        uint256 voteCount;
        LChainLink.Link link;
    }

    // variables
    /// @dev belong to which DAO
    address internal _parentDAO;

    /// @dev all committee's duties stored here
    EnumerableSet.Bytes32Set committeeDuties;

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
        // committeeDuties.add(keccak256(data));
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
    {}

    /// @inheritdoc IVoteHandler
    function getVoteDetailByAccount(
        VoteIdentity calldata identity,
        address account
    ) external view override returns (uint256 agreeVotes, uint256 denyVotes) {
        return _getProposalAccountDetail(identity._getIdentityID(), account);
    }

    /// @inheritdoc IVoteHandler
    function getVoteSummary(VoteIdentity calldata identity)
        public
        view
        virtual
        override
        returns (VoteInfo memory result)
    {
        return _voteInfos[identity._getIdentityID()];
    }

    /// @inheritdoc ICommittee
    function allowOperate(VoteIdentity calldata identity, address user)
        public
        view
        virtual
        override
        returns (bool)
    {
        // IProposalRegistryInfo.Proposal memory proposal = _getProposalInfo(
        //     identity.proposalID
        // );
        // return _checkAllowOperate(proposal, identity, user);
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
        // Proposal memory proposal = _getProposalInfo(
        //     identity.proposalID
        // );

        // require(
        //     _checkAllowOperate(proposal, identity, _msgSender()),
        //     "not allow"
        // );

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

    /// @inheritdoc IVoteHandler
    function vote(
        VoteIdentity calldata identity,
        bool agree,
        uint256 count,
        string calldata feedback,
        bytes calldata data
    ) external override {
        _vote(identity, agree, count, true, feedback, data);
    }

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

        console.log("current: ", currentVoter);

        while (idx < pageSize && !LChainLink._isEmpty(currentVoter)) {
            console.log("start loop");

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

    // function _checkAllowOperate(
    //     Proposal memory proposal,
    //     VoteIdentity calldata identity,
    //     address user
    // ) internal view returns (bool) {

    //     if (!isCommitteeMember(user)) {
    //         return false;
    //     }

    //     if (!_checkProposalStatus(proposal, identity)) {
    //         return false;
    //     }

    //     if (!_checkSensitivePosition(proposal, user)) {
    //         return false;
    //     }

    //     if (_checkDeadline(proposal)) {
    //         return false;
    //     }

    //     if(!_checkBadge(proposal, user)){
    //       return false;
    //     }

    //     return true;
    // }

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
