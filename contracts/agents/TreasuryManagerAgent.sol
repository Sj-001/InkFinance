//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "hardhat/console.sol";

contract TreasuryManagerAgent is BaseAgent {
    string internal constant _MD_SIGNERS = "Signers";
    string internal constant _MD_OPERATORS = "Operators";
    string internal constant _MD_INCOME_AUDITORS = "IncomeAuditors";
    string internal constant _MD_EXP_AUDITORS = "ExpAuditors";

    bytes32 public FLOW_ID = "";

    function init(
        address dao_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
    }

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

        // TreasuryCommittee.InitData memory tInitData;

        // Committee.BaseInitData memory bInitData;
        // bInitData.name = "treasury-committee";
        // bInitData.describe = "";
        // tInitData.baseInitData = abi.encode(bInitData);

        // TreasuryCommittee tAddr = new TreasuryCommittee();
        // tAddr.init(address(this), address(addrRegistry), abi.encode(tInitData));

        // //////////////////// treasury init member
        bytes32 typeID;
        bytes memory committeeKey;
        bytes memory controllerAddressBytes;

        console.log("check in agent");

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());

        (typeID, committeeKey) = proposalHandler.getProposalMetadata(
            proposalID,
            "committeeKey"
        );
        // console.logBytes(committeeKey);
        bytes32 committeeKeyBytes32 = turnBytesToBytes32(committeeKey);
        // console.logBytes32(committeeKeyBytes32);

        // // console.logBytes32(committeeKeyBytes32);
        // bytes memory initData = abi.encode("");
        // bytes memory deployCall = abi.encodeWithSignature(
        //     "deployByKey(bytes32,bytes32,bytes)",
        //     0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f,
        //     committeeKeyBytes32,
        //     initData
        // );

        // (bool success, bytes memory returnedBytes) = address(
        //     getAgentDAO()
        // ).call(deployCall);

        // console.log("deploy committee :");
        // console.log(success);
        // console.logBytes(returnedBytes);

        (typeID, controllerAddressBytes) = proposalHandler.getProposalMetadata(
            proposalID,
            "controllerAddress"
        );
        console.logBytes(controllerAddressBytes);

        //
        // ////////// signers
        // (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_SIGNERS);
        // require(typeID == TypeID.ADDRESS_SLICE, "signers not addr[]");
        // setMemberList(tAddr, data, DutyID.SIGNER);

        /*
        ////////// operators
        (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_OPERATORS);
        require(typeID == TypeID.ADDRESS_SLICE, "operators not addr[]");
        setMemberList(tAddr, data, DutyID.OPERATOR);

        ////////// income auditor
        (typeID, data) = proposalRegistry.getProposalKvData(proposalID, _MD_INCOME_AUDITORS);
        require(typeID == TypeID.ADDRESS_SLICE, "INCOME_AUDITORS not addr[]");
        setMemberList(tAddr, data, DutyID.INCOME_AUDITOR);
        */

        ////////// set dao
        IProposalHandler.FlowInfo memory flowInfo;
        flowInfo.flowID = keccak256(abi.encode("financial"));

        IProposalHandler.CommitteeCreateInfo memory theBoard;
        theBoard.step = keccak256(abi.encode("generate proposal"));
        theBoard.addressConfigKey = keccak256(abi.encode("generate proposal"));
        bytes32[] memory duty1 = new bytes32[](1);

        duty1[
            0
        ] = 0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e;
        theBoard.dutyIDs = abi.encode(duty1);

        IProposalHandler.CommitteeCreateInfo memory theTreasuryCommittee;
        theTreasuryCommittee.step = keccak256(
            abi.encode("treasury proposal vote")
        );
        theTreasuryCommittee.addressConfigKey = committeeKeyBytes32;
        bytes32[] memory duty2 = new bytes32[](1);
        duty2[
            0
        ] = 0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e;
        theTreasuryCommittee.dutyIDs = abi.encode(duty2);

        flowInfo.committees = new IProposalHandler.CommitteeCreateInfo[](2);
        flowInfo.committees[0] = theBoard;
        flowInfo.committees[1] = theTreasuryCommittee;

        IDAO(getAgentDAO()).setupFlowInfo(flowInfo);

        // flowInfo.committees[0].step = flowInfo.flowID;
        // flowInfo.committees[0].committee = address(tAddr);

        // DAO(address(this)).setFlowStep(flowInfo);
        // DAO(address(this)).setUCV(address(new InkPayManager(address(this))));
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

    function turnBytesToBytes32(bytes memory originBytes)
        internal
        pure
        returns (bytes32)
    {
        bytes32 targetBytes32;

        assembly {
            targetBytes32 := mload(add(originBytes, 32))
        }

        return targetBytes32;
    }
}
