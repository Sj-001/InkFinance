//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../libraries/defined/DutyID.sol";
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
        bytes32 typeID;
        bytes memory dataBytes;
        console.log("pre exec TreasuryManagerAgent ");

        // valid related address，include operator ｜ multisigner ｜ auditor

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "operators"
        );
        address[] memory operators = abi.decode(dataBytes, (address[]));

        console.log(
            "operator address ::::::::::::::::::::::::::::::::: ",
            operators[0]
        );

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "signer"
        );

        address[] memory signers = abi.decode(dataBytes, (address[]));
        console.log(
            "signer address ::::::::::::::::::::::::::::::::: ",
            signers[0]
        );

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "auditor"
        );
        address[] memory auditors = abi.decode(dataBytes, (address[]));
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

        // //////////////////// treasury init member
        bytes32 typeID;
        bytes memory memberBytes;
        bytes memory bytesData;
        bytes memory committeeKey;
        bytes memory controllerAddressBytes;

        console.log("check in agent");

        IProposalHandler proposalHandler = IProposalHandler(getAgentDAO());
        (typeID, committeeKey) = proposalHandler.getProposalMetadata(
            proposalID,
            "committeeKey"
        );

        // _setupFlowInfo(committeeKey.toBytes32());

        (typeID, controllerAddressBytes) = proposalHandler.getProposalMetadata(
            proposalID,
            "controllerAddress"
        );

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "operators"
        );

        // const OPERATOR_DUTYID = "0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4";
        _setMemberDuties(DutyID.OPERATOR, memberBytes);

        // const SIGNER_DUTYID = "0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f";
        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "signer"
        );

        _setMemberDuties(DutyID.SIGNER, memberBytes);
        // address[] memory signers = abi.decode(signerBytes, (address[]));
        // console.log("signer address ::::::::::::::::::::::::::::::::: ", signers[0]);
        // const AUDITOR_DUTYID = "0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb";
        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            "auditor"
        );

        _setMemberDuties(DutyID.AUDITOR, memberBytes);
        // address[] memory auditors = abi.decode(auditorBytes, (address[]));
        // console.log("auditor address ::::::::::::::::::::::::::::::::: ", auditors[0]);

        // setup committee
        bytes32[] memory duties = new bytes32[](3);
        duties[0] = DutyID.OPERATOR;
        duties[1] = DutyID.SIGNER;
        duties[2] = DutyID.AUDITOR;
        bytes memory dutyIDs = abi.encode(duties);
        IDAO(_dao).setupCommittee(
            "Treasury Committee",
            committeeKey.toBytes32(),
            dutyIDs
        );

        // setup payroll & payroll ucv
        (typeID, bytesData) = proposalHandler.getProposalMetadata(
            proposalID,
            "ucvKey"
        );
        address ucvAddress = IDAO(_dao).deployByKey(
            typeID,
            bytesData.toBytes32(),
            abi.encode("")
        );

        (typeID, bytesData) = proposalHandler.getProposalMetadata(
            proposalID,
            "ucvManagerKey"
        );
        IDAO(_dao).deployByKey(
            typeID,
            bytesData.toBytes32(),
            abi.encode(ucvAddress)
        );
    }

    function _setMemberDuties(bytes32 dutyID, bytes memory memberBytes)
        internal
    {
        address[] memory members = abi.decode(memberBytes, (address[]));
        for (uint256 i = 0; i < members.length; i++) {
            console.log("_setMemberDuties :", members[i]);
            IDAO(_dao).addDuty(members[i], dutyID);
        }
    }

    // function _setupFlowInfo(bytes32 committeeKey) internal {
    //     IProposalHandler.FlowInfo
    //         memory payrollSetupflowInfo = _buildPayrollSetupFlow(committeeKey);

    //     console.log(
    //         "start to generate payroll flow ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    //     );

    //     IDAO(getAgentDAO()).setupFlowInfo(payrollSetupflowInfo);

    //     IProposalHandler.FlowInfo
    //         memory payrollSignflowInfo = _buildPayrollPayFlow(committeeKey);
    //     IDAO(getAgentDAO()).setupFlowInfo(payrollSignflowInfo);
    // }

    /*
    function _buildPayrollSetupFlow(bytes32 committeeKey)
        internal
        view
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
        theTreasuryCommittee.committeeName = "Treasury Committee";

        bytes32[] memory dutys = new bytes32[](3);
        // make financial proposl(create payroll)
        dutys[0] = DutyID.OPERATOR;
        dutys[1] = DutyID.SIGNER;
        dutys[2] = DutyID.AUDITOR;

        theTreasuryCommittee.dutyIDs = abi.encode(dutys);

        flowInfo.committees = new IProposalHandler.CommitteeCreateInfo[](1);
        flowInfo.committees[0] = theTreasuryCommittee;
    }

    function _buildPayrollPayFlow(bytes32 committeeKey)
        internal
        view
        returns (IProposalHandler.FlowInfo memory flowInfo)
    {
        flowInfo.flowID = keccak256("financial-payroll-pay");
        console.log("financial-payroll-pay:");
        console.logBytes32(flowInfo.flowID);
        // Flow[0] generate payroll, Operator could create that kind of proposal.
        IProposalHandler.CommitteeCreateInfo memory theTreasuryCommittee;
        // create agent - after passed, should set up
        theTreasuryCommittee.step = keccak256(abi.encode("sign-payroll"));

        theTreasuryCommittee.committeeName = "Treasury Committee";
        // treasury committee
        theTreasuryCommittee.addressConfigKey = committeeKey;
        bytes32[] memory duties = new bytes32[](3);
        duties[0] = DutyID.OPERATOR;
        duties[1] = DutyID.SIGNER;
        duties[2] = DutyID.AUDITOR;
        // make financial proposl(create payroll)

        theTreasuryCommittee.dutyIDs = abi.encode(duties);

        flowInfo.committees = new IProposalHandler.CommitteeCreateInfo[](1);
        flowInfo.committees[0] = theTreasuryCommittee;
    }
    */

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
