//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseDAO.sol";
import "hardhat/console.sol";

contract MasterDAO is BaseDAO {
    /// libs ////////////////////////////////////////////////////////////////////////
    using Address for address;

    /// structs ////////////////////////////////////////////////////////////////////////

    /// @notice MasterDAO initial data, when create dao,
    /// these data is necessary for creating the DAO instance.
    /// @param name DAO name
    /// @param describe DAO's description
    /// @param mds DAO's meta data
    /// @param govTokenAddr DAO's governance token
    /// @param govTokenAmountRequirement base requirement token amount for createing the DAO
    /// @param stakingAddr DAO's staking engine address
    /// @param flows operate flows of the DAO
    /// @param badgeName the badge name of the DAO
    /// @param badgeTotal how many badges in the DAO
    /// @param daoLogo dao's logo image path on internet or IFPS/AR/
    /// @param minPledgeRequired minimal token needed to pledge
    /// @param minEffectiveVotes minimal effective votes
    /// @param minEffectiveVoteWallets minimal effective vote wallets
    struct MasterDAOInitData {
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        string badgeName;
        uint256 badgeTotal;
        string daoLogo;
        uint256 minPledgeRequired;
        uint256 minEffectiveVotes;
        uint256 minEffectiveVoteWallets;
        // FlowInfo[] flows;
    }


    /// @dev dao inforamtion
    MasterDAOInitData private _daoInitData;

    /// @dev 
    // keccak256("dao.category.NORMAL_CATEGORY")
    bytes32 public constant NORMAL_CATEGORY =
        0xe74eb57e65d8bc05567c1f87e30b997b8d307f4263f0ff5b4b3a4a7f3a49fd90;

    /// variables ////////////////////////////////////////////////////////////////////////
    /// @dev frontend tools to build init data
    function buildInitData(MasterDAOInitData memory initData)
        public
        pure
        returns (bytes memory data)
    {
        return abi.encode(initData);
    }

    function init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        ownerAddress = admin_;
        // _metadata._init();
        _daoInitData = abi.decode(data, (MasterDAOInitData));

        // name = initData.name;
        // describe = initData.describe;
        // govToken = initData.govTokenAddr;

        // _metadata._setBytesSlice(initData.mds);
        // govTokenAmountRequirement = initData.govTokenAmountRequirement;
        // stakingAddr = initData.stakingAddr;

        // require(initData.flows.length != 0, "no flow set");
        // for (uint256 i = 0; i < initData.flows.length; i++) {
        //     _setFlowStep(initData.flows[i]);
        // }

        // if(bytes(initData.badgeName).length != 0){
        //   _badge = InkBadgeERC20Factory(IAddressRegistry(addrRegistry).getAddress(AddressID.InkBadgeERC20Factory)).CreateBadge(initData.badgeName, initData.badgeName, initData.badgeTotal, admin);
        //   emit EBadge(_badge, initData.name, initData.badgeTotal);
        // }

        CallbackData memory callbackData;
        callbackData.addr = address(this);
        callbackData.admin = admin_;
        callbackData.govTokenAddr = address(govToken);
        callbackData.name = name;
        return abi.encode(callbackData);
    }

    /// @dev makeing a new proposal,
    /// @param   proposal content
    /// @param data related content
    /// @return proposalID
    function newProposal(
        ProposalApplyInfo calldata proposal,
        bytes calldata data
    ) public override EnsureGovEnough returns (bytes32 proposalID) {
        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            NORMAL_CATEGORY
        ];

        // bytes32 firstStep = steps[_SENTINEL_ID].nextStep;

        // require(firstStep != bytes32(0x0), "sys err");
        // require(_msgSender() == steps[firstStep].committee, "no right");

        // IProposalRegistry proposalRegistry = _getProposalRegistry();
        // proposalID = proposalRegistry.newProposal(proposal, data);

        // // initial process of the progress
        // DAOProcessInfo storage info = _proposalInfo[proposalID];
        // info.proposalID = proposalID;
        // info.processCategory = NORMAL_CATEGORY;

        // // decicde next step and which commit is handle the process
        // info.nextCommittee.step = firstStep;
        // info.nextCommittee.committee = _msgSender();

        // _decideProposal(proposalID, _msgSender(), true);
    }


    /*
        // flows := make([]MasterDAO.IDAOFlowInfo, 1)
        // flows[0] = MasterDAO.IDAOFlowInfo{
        // Committees: []MasterDAO.IDAOHandleProposalProposalCommitteeInfo{
        // 	{
        // 		Step:      crypto.Keccak256Hash([]byte("generate proposal")),
        // 		Committee: addrMap[cfg.App.ProposalCommitteeFactoryID],
        // 		Sensitive: big.NewInt(1),
        // 	},
        // 	{
        // 		Step:      crypto.Keccak256Hash([]byte("public vote")),
        // 		Committee: addrMap[cfg.App.PublicVoteCommitteeFactoryID],
        // 		Sensitive: big.NewInt(0),
        // 	},
        // 	// {
        // 	// 	Step:      crypto.Keccak256Hash([]byte("member vote")),
        // 	// 	Committee: addrMap[cfg.App.MemberVoteCommitteeFactoryID],
        // 	// },
        // },

        // FlowID: common.HexToHash("0xe74eb57e65d8bc05567c1f87e30b997b8d307f4263f0ff5b4b3a4a7f3a49fd90"),
    */


    //////////////////// internal
    function _setFlowStep(FlowInfo memory flow) internal {
        require(flow.committees.length < MAX_STEP_NUM, "too many steps");

        mapping(bytes32 => StepLinkInfo) storage steps = _flowSteps[
            flow.flowID
        ];

        // init sentinel.
        steps[_SENTINEL_ID].nextStep = flow.committees[0].step;

        for (uint256 j = 0; j < flow.committees.length; j++) {
            CommitteeInfo memory committeeInfo = flow.committees[j];

            require(
                committeeInfo.step != bytes32(0x0) &&
                    committeeInfo.step != _SENTINEL_ID,
                "step empty"
            );

            // require(
            //     BaseCommittee(committeeInfo.committee).supportsInterface(
            //         type(ICommittee).interfaceId
            //     ),
            //     "committee addr not support ICommittee"
            // );

            steps[committeeInfo.step].committee = committeeInfo.committee;
            steps[committeeInfo.step].sensitive = committeeInfo.sensitive;

            // link next committee
            if (j < flow.committees.length - 1) {
                steps[committeeInfo.step].nextStep = flow
                    .committees[j + 1]
                    .step;
            } else {
                steps[committeeInfo.step].nextStep = bytes32(0x0);
            }
        }
    }

    function getDAOProcessInfo(bytes32 proposalID)
        external
        view
        override
        returns (DAOProcessInfo memory info)
    {}

    function getNextCommittee(bytes32 proposalID)
        external
        view
        override
        returns (CommitteeInfo memory nextInfo)
    {}

    function getLastOperationTimestamp(bytes32 proposalID)
        external
        view
        override
        returns (uint256 timestamp)
    {}

    function getProposalStep(bytes32 proposalID, uint256 stepIdx)
        external
        view
        override
        returns (CommitteeInfo memory stepInfo)
    {}
}
