//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseAgent.sol";
import "hardhat/console.sol";

contract TreasuryManagerAgent is BaseAgent {
    bytes32 public FLOW_ID = "";

    function init(
        address admin_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IAgent
    function preExec(bytes32 proposalID)
        external
        override
        returns (bool success)
    {
        // valid, if it's proposl, etc.
        console.log(
            "pre exec --------------------------------------------------------------------------------- "
        );
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override {
        /*
            address to;
            uint256 value;
            bytes data;
            uint256 gasLimit;
        */
        // TxInfo[] memory txs;
        // txs[0] = TxInfo(address(0), 1, bytes(""), 1);

        console.log(
            "exec --------------------------------------------------------------------------------- "
        );

        //////////////////// get platform addr
        // IAddressRegistry addrRegistry = BaseVerify(address(this)).addrRegistry();

        // IProposalRegistry proposalRegistry = IProposalRegistry(
        //     addrRegistry.getAddress(AddressID.PROPOSAL_REGISTRY)
        // );

        //////////////////// create treasury

        /*
        TreasuryCommittee.InitData memory tInitData;

        Committee.BaseInitData memory bInitData;
        bInitData.name = "treasury-committee";
        bInitData.describe = "";

        tInitData.baseInitData = abi.encode(bInitData);

        TreasuryCommittee tAddr = new TreasuryCommittee();
        tAddr.init(address(this), address(addrRegistry), abi.encode(tInitData));

        //////////////////// treasury init member
        bytes32 typeID;
        bytes memory data;

        ////////// signers
        (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_SIGNERS);
        require(typeID == TypeID.ADDRESS_SLICE, "signers not addr[]");
        setMemberList(tAddr, data, DutyID.SIGNER);

        ////////// operators
        (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_OPERATORS);
        require(typeID == TypeID.ADDRESS_SLICE, "operators not addr[]");
        setMemberList(tAddr, data, DutyID.OPERATOR);

        ////////// income auditor
        (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_INCOME_AUDITORS);
        require(typeID == TypeID.ADDRESS_SLICE, "INCOME_AUDITORS not addr[]");
        setMemberList(tAddr, data, DutyID.INCOME_AUDITOR);


        ////////// set dao
        DAO.FlowInfo memory flowInfo;
        flowInfo.flowID = keccak256(abi.encode("financial"));
        flowInfo.committees = new IDAOHandleProposal.ProposalCommitteeInfo[](1);
        flowInfo.committees[0].step = flowInfo.flowID;
        flowInfo.committees[0].committee = address(tAddr);
        
        DAO(address(this)).setFlowStep(flowInfo);
        DAO(address(this)).setUCV(address(new InkPayManager(address(this))));
        */
    }

    function getTypeID() external view override returns (bytes32 typeID) {}

    function getVersion() external view override returns (uint256 version) {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IAgent).interfaceId;
    }
}
