//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../utils/BytesUtils.sol";
import "hardhat/console.sol";

contract TreasuryManagerAgent is BaseAgent {
    using BytesUtils for bytes;

    string internal constant _MD_SIGNERS = "Signers";
    string internal constant _MD_OPERATORS = "Operators";
    string internal constant _MD_INCOME_AUDITORS = "IncomeAuditors";
    string internal constant _MD_EXP_AUDITORS = "ExpAuditors";

    address private _dao;

    function init(
        address dao_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        _dao = dao_;
    }

    /// @inheritdoc IAgent
    function preExec(bytes32 proposalID)
        external
        override
        returns (bool success)
    {
        // verify the treasury has been set up before

        console.log("pre exec TreasuryManagerAgent ");

        // valid related address，include operator ｜ multisigner ｜ auditor

        (bytes32 typeID, bytes memory operatorBytes) = IProposalHandler(_dao)
            .getProposalKvData(proposalID, "operators");

        address[] memory operators = abi.decode(operatorBytes, (address[]));

        console.log(
            "operator address ::::::::::::::::::::::::::::::::: ",
            operators[0]
        );

        (bytes32 typeID2, bytes memory signerBytes) = IProposalHandler(_dao)
            .getProposalKvData(proposalID, "signer");

        address[] memory signers = abi.decode(signerBytes, (address[]));
        console.log(
            "signer address ::::::::::::::::::::::::::::::::: ",
            signers[0]
        );

        (bytes32 typeID3, bytes memory auditorBytes) = IProposalHandler(_dao)
            .getProposalKvData(proposalID, "auditor");
        address[] memory auditors = abi.decode(auditorBytes, (address[]));
        console.log(
            "auditor address ::::::::::::::::::::::::::::::::: ",
            auditors[0]
        );

        success = true;
    }

    /// @inheritdoc IAgent
    function exec(bytes32 proposalID) external override onlyCallFromDAO {
        console.log(
            "TreasuryManagerAgent exec --------------------------------------------------------------------------------- "
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
        bytes memory memberBytes;

        bytes memory committeeKey;
        bytes memory controllerAddressBytes;

        console.log("check in agent");

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());
        (typeID, committeeKey) = proposalHandler.getProposalMetadata(
            proposalID,
            "committeeKey"
        );

        _setupFlowInfo(committeeKey.toBytes32());

        (typeID, controllerAddressBytes) = proposalHandler.getProposalMetadata(
            proposalID,
            "controllerAddress"
        );

        console.logBytes(controllerAddressBytes);
        // address controllerAddress = controllerAddressBytes.toAddress();

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

        // console.log("OPERATOR_DUTYID=", keccak256(toUtf8Bytes("dutyID.OPERATOR")));
        // console.log("SIGNER_DUTYID=", keccak256(toUtf8Bytes("dutyID.SIGNER")));
        // console.log("AUDITOR_DUTYID=", keccak256(toUtf8Bytes("dutyID.AUDITOR")));

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "operators"
        );
        // const OPERATOR_DUTYID = "0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4";
        _setMemberDuties(
            0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4,
            memberBytes
        );
        // const SIGNER_DUTYID = "0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f";
        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "signer"
        );
        _setMemberDuties(
            0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f,
            memberBytes
        );
        // address[] memory signers = abi.decode(signerBytes, (address[]));
        // console.log("signer address ::::::::::::::::::::::::::::::::: ", signers[0]);
        // const AUDITOR_DUTYID = "0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb";
        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "auditor"
        );
        _setMemberDuties(
            0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb,
            memberBytes
        );
        // address[] memory auditors = abi.decode(auditorBytes, (address[]));
        // console.log("auditor address ::::::::::::::::::::::::::::::::: ", auditors[0]);
    }

    function _setMemberDuties(bytes32 dutyID, bytes memory memberBytes)
        internal
    {
        address[] memory members = abi.decode(memberBytes, (address[]));
        for (uint256 i = 0; i < members.length; i++) {
            IDAO(_dao).addDuty(members[i], dutyID);
        }
    }

    function _setupFlowInfo(bytes32 committeeKey) internal {
        IProposalHandler.FlowInfo
            memory payrollSetupflowInfo = _buildPayrollSetupFlow(committeeKey);

        console.log(
            "start to generate payroll flow ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        );

        IDAO(getAgentDAO()).setupFlowInfo(payrollSetupflowInfo);

        IProposalHandler.FlowInfo
            memory payrollSignflowInfo = _buildPayrollPayFlow(committeeKey);
        IDAO(getAgentDAO()).setupFlowInfo(payrollSignflowInfo);
    }

    function _buildPayrollSetupFlow(bytes32 committeeKey)
        internal
        returns (IProposalHandler.FlowInfo memory flowInfo)
    {
        flowInfo.flowID = keccak256("financial-payroll-setup");

        console.log("financial-payroll-setup:");
        console.logBytes32(flowInfo.flowID);
        // Flow[0] generate payroll, Operator could create that kind of proposal.
        IProposalHandler.CommitteeCreateInfo memory theTreasuryCommittee;
        // create agent - after passed, should set up
        theTreasuryCommittee.step = keccak256(
            abi.encode("generate payroll setup")
        );
        // treasury committee
        theTreasuryCommittee.addressConfigKey = committeeKey;
        bytes32[] memory duty1 = new bytes32[](1);
        // make financial proposl(create payroll)
        duty1[
            0
        ] = 0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e;

        theTreasuryCommittee.dutyIDs = abi.encode(duty1);
        flowInfo.committees = new IProposalHandler.CommitteeCreateInfo[](1);
        flowInfo.committees[0] = theTreasuryCommittee;
    }

    function _buildPayrollPayFlow(bytes32 committeeKey)
        internal
        returns (IProposalHandler.FlowInfo memory flowInfo)
    {
        flowInfo.flowID = keccak256("financial-payroll-pay");
        console.log("financial-payroll-pay:");
        console.logBytes32(flowInfo.flowID);
        // Flow[0] generate payroll, Operator could create that kind of proposal.
        IProposalHandler.CommitteeCreateInfo memory theTreasuryCommittee;
        // create agent - after passed, should set up
        theTreasuryCommittee.step = keccak256(abi.encode("sign-payroll"));
        // treasury committee
        theTreasuryCommittee.addressConfigKey = committeeKey;
        bytes32[] memory duty1 = new bytes32[](1);
        // make financial proposl(create payroll)
        duty1[
            0
        ] = 0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e;

        theTreasuryCommittee.dutyIDs = abi.encode(duty1);
        flowInfo.committees = new IProposalHandler.CommitteeCreateInfo[](1);
        flowInfo.committees[0] = theTreasuryCommittee;
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

    function isUniqueInDAO() external override returns (bool isUnique) {
        isUnique = true;
    }
}
