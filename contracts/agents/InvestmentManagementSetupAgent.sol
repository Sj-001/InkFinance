//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../committee/TreasuryCommittee.sol";
import "../bases/BaseAgent.sol";
import "../interfaces/IDAO.sol";
import "../libraries/defined/DutyID.sol";
import "../utils/BytesUtils.sol";
import "hardhat/console.sol";

contract InvestmentManagementSetupAgent is BaseAgent {
    using BytesUtils for bytes;

    string internal constant FUND_ADMIN = "fundAdmin";
    string internal constant FUND_MANAGER = "fundManager";
    string internal constant FUND_RISK_MANAGER = "fundRiskManager";
    string internal constant FUND_LIQUIDATOR = "fundLiquidator";
    string internal constant FUND_AUDITOR = "fundAuditor";

    address private _dao;

    function init(
        address dao_,
        address config_,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {
        super.init(config_);
        console.log("init1234");
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
        console.log("pre exec InvestmentManagementSetupAgent ");

        // valid related address，include operator ｜ multisigner ｜ auditor

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_ADMIN
        );
        address[] memory fundAdmin = abi.decode(dataBytes, (address[]));

        console.log(
            "fundAdmin address ::::::::::::::::::::::::::::::::: ",
            fundAdmin[0]
        );

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_MANAGER
        );

        address[] memory fundManager = abi.decode(dataBytes, (address[]));
        console.log(
            "fundManager address ::::::::::::::::::::::::::::::::: ",
            fundManager[0]
        );

        (, dataBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_RISK_MANAGER
        );
        address[] memory ristManager = abi.decode(dataBytes, (address[]));
        console.log(
            "auditor address ::::::::::::::::::::::::::::::::: ",
            ristManager[0]
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

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_ADMIN
        );
        _setMemberDuties(DutyID.FUND_ADMIN, memberBytes);

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_MANAGER
        );
        _setMemberDuties(DutyID.FUND_MANAGER, memberBytes);

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_RISK_MANAGER
        );
        _setMemberDuties(DutyID.FUND_RISK_MANAGER, memberBytes);

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_LIQUIDATOR
        );
        _setMemberDuties(DutyID.FUND_LIQUIDATOR, memberBytes);

        (typeID, memberBytes) = IProposalHandler(_dao).getProposalKvData(
            proposalID,
            FUND_AUDITOR
        );
        _setMemberDuties(DutyID.FUND_AUDITOR, memberBytes);

        // setup committee
        bytes32[] memory duties = new bytes32[](5);
        duties[0] = DutyID.FUND_ADMIN;
        duties[1] = DutyID.FUND_MANAGER;
        duties[2] = DutyID.FUND_RISK_MANAGER;
        duties[3] = DutyID.FUND_LIQUIDATOR;
        duties[4] = DutyID.FUND_AUDITOR;

        bytes memory dutyIDs = abi.encode(duties);

        IDAO(_dao).setupCommittee(
            "Investment Committee",
            committeeKey.toBytes32(),
            dutyIDs
        );

        (typeID, bytesData) = proposalHandler.getProposalMetadata(
            proposalID,
            "ucvManagerKey"
        );

        // deploy ucv manager
        address ucvManager = IDAO(_dao).deployByKey(
            typeID,
            bytesData.toBytes32(),
            abi.encode(proposalID)
        );

        _executed = true;
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
