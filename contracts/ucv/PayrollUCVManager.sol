//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../bases/BaseUCVManager.sol";
import "../interfaces/IPayrollManager.sol";
import "../interfaces/IDAO.sol";
import "../interfaces/IUCV.sol";

import "../utils/ProposalHelper.sol";

import "hardhat/console.sol";

contract PayrollUCVManager is IPayrollManager, BaseUCVManager {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using ProposalHelper for IProposalInfo.Proposal;

    event Withdraw(
        uint256 indexed id,
        address indexed addr,
        uint256 indexed hasTimeID,
        uint256 total,
        address coin
    );

    struct PayrollSchedule {
        // member addr -> member.
        // mapping(address => PayrollScheduleMember) members;
        uint256 claimPeriod;
        uint256 availableTimes;
        uint256 startTime;
        uint256 approvedTimes;
    }

    mapping(bytes32 => address) private _payrollUCVs;

    // payroll item
    // PropsalID(payroll setup Proposal)=>ScheduleInfo
    mapping(bytes32 => PayrollSchedule) private _schedules;

    // PropsalID(payroll setup Proposal)=>Removed member address
    mapping(bytes32 => EnumerableSet.AddressSet) private _removedMembers;

    // PropsalID(payroll setup Proposal)=>the time to removed member address from the payroll
    mapping(bytes32 => mapping(address => uint256)) private _removedMoment;

    // PropsalID(payroll setup Proposal)=>the times the user claimed from the payroll
    mapping(bytes32 => mapping(address => uint256)) private _userClaims;

    /// @dev proposalID=>payrollBatch=>1=vote passed, 0=not voted yet.
    mapping(bytes32 => mapping(uint256 => uint256))
        private _payrollBatchVoteInfo;

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _dao = dao_;
        // @dev init controller and manager address
        address controller = abi.decode(data_, (address));
        bytes memory initData = abi.encode(controller, address(this));
        // console.log("here ucv address is:", _ucv);
    }

    /// @dev todo todo DAO only
    /// @inheritdoc IPayrollManager
    function setupPayroll(bytes32 proposalID, address ucv)
        external
        override
        daoOnly
    {
        _payrollUCVs[proposalID] = ucv;

        console.log(
            "set up payroll ------------------------------------------------------------------------------------------------------------------------------------------------------------------ "
        );

        console.log("dao is:", _dao);
        console.log("proposalID is:");
        console.logBytes32(proposalID);

        IProposalHandler proposalHandler = IProposalHandler(_dao);

        bytes32 topicID = proposalHandler.getProposalTopic(proposalID);

        bytes32 typeID;
        bytes memory bytesData;
        (typeID, bytesData) = proposalHandler.getTopicKVdata(
            topicID,
            "startTime"
        );

        uint256 startTime = abi.decode(bytesData, (uint256));

        (typeID, bytesData) = proposalHandler.getTopicKVdata(topicID, "period");
        uint256 period = abi.decode(bytesData, (uint256));

        (typeID, bytesData) = proposalHandler.getTopicKVdata(
            topicID,
            "claimTimes"
        );

        uint256 claimTimes = abi.decode(bytesData, (uint256));

        PayrollSchedule storage schedule = _schedules[topicID];
        schedule.startTime = startTime;
        schedule.availableTimes = claimTimes;
        schedule.claimPeriod = period;
        schedule.approvedTimes = 0;

        console.log("payroll schedule setup:");
        console.logBytes32(topicID);

        (typeID, bytesData) = proposalHandler.getProposalMetadata(
            proposalID,
            "SubCategory"
        );
        console.log("subcategory bytes:");
        console.logBytes(bytesData);

        string memory subCategory = abi.decode(bytesData, (string));
        console.log("sub category:", subCategory);

        // emit event
        emit NewPayrollSetup(
            proposalID,
            topicID,
            subCategory,
            period,
            claimTimes,
            startTime
        );

        // start get payee topic:
        console.log("start get payee topic");

        PayrollScheduleMember[] memory payees = getPayeeInTopic(topicID);

        console.log("payee members", payees.length);

        (typeID, bytesData) = proposalHandler.getTopicKVdata(
            topicID,
            "members"
        );

        PayrollScheduleMember[] memory payrollMembers = abi.decode(
            bytesData,
            (PayrollScheduleMember[])
        );

        console.log(payrollMembers.length);

        for (uint256 i = 0; i < payrollMembers.length; i++) {
            emit PayrollMemberAdded(
                topicID,
                payrollMembers[i].memberAddress,
                payrollMembers[i].token,
                payrollMembers[i].oncePay,
                bytes("")
            );
        }

        if (startTime <= block.timestamp) {
            // approved once
            _approvePayrollBatch(proposalID, 1);
        }
    }

    function _getPayeeCountInTopic(bytes32 topicID)
        internal
        returns (uint256 payeeCount)
    {
        IProposalHandler proposalHandler = IProposalHandler(_dao);
        bytes32 typeID;
        bytes memory bytesData;
        // 2000 should also be a variable

        uint256 keepNoneLimit = 5;
        uint256 currentNone = 0;
        for (uint256 i = 0; i < 2000; i++) {
            string memory keyIs = string(
                abi.encodePacked("payee-", i.toString())
            );
            console.log("the key is: ", keyIs);

            (typeID, bytesData) = proposalHandler.getTopicKVdata(
                topicID,
                keyIs
            );

            if (bytesData.length > 0) {
                currentNone = 0;
                payeeCount++;
            } else {
                currentNone++;
                if (currentNone >= keepNoneLimit) {
                    break;
                }
            }
        }
    }

    function getPayeeInTopic(bytes32 topicID)
        internal
        returns (PayrollScheduleMember[] memory payees)
    {
        IProposalHandler proposalHandler = IProposalHandler(_dao);
        bytes32 typeID;
        bytes memory bytesData;
        // 2000 should also be a variable
        payees = new PayrollScheduleMember[](_getPayeeCountInTopic(topicID));

        uint256 keepNoneLimit = 5;
        uint256 currentNone = 0;

        uint256 payeeIndex = 0;

        for (uint256 i = 0; i < 2000; i++) {
            string memory keyIs = string(
                abi.encodePacked("payee-", i.toString())
            );
            console.log("the key is: ", keyIs);

            (typeID, bytesData) = proposalHandler.getTopicKVdata(
                topicID,
                keyIs
            );

            if (bytesData.length > 0) {
                currentNone = 0;
                (
                    address payee,
                    address token,
                    uint256 amount,
                    string memory describe
                ) = abi.decode(bytesData, (address, address, uint256, string));
                console.log("Payroll UCV Manager:::::::", payee);

                payees[payeeIndex].memberAddress = payee;
                payees[payeeIndex].token = token;
                payees[payeeIndex].oncePay = amount;
                payees[payeeIndex].scheduleType = describe;
            } else {
                currentNone++;
                if (currentNone >= keepNoneLimit) {
                    break;
                }
            }
        }
    }

    // agent only

    /// @inheritdoc IPayrollManager
    function approvePayrollBatch(bytes32 proposalID, uint256 approveID)
        external
        override
    {
        _approvePayrollBatch(proposalID, approveID);
    }

    function _approvePayrollBatch(bytes32 proposalID, uint256 approvedTimes)
        internal
    {
        bytes32 topicID = IProposalHandler(_dao).getProposalTopic(proposalID);

        PayrollSchedule storage schedule = _schedules[topicID];
        schedule.approvedTimes = schedule.approvedTimes + approvedTimes;

        emit ApprovePayrollBatch(proposalID, topicID, approvedTimes);
    }

    /// @inheritdoc IPayrollManager
    function claimPayroll(bytes32 topicID) external override {
        // calculate amount
        (
            uint256 leftTimes,
            uint256 leftAmount,
            address token
        ) = _getClaimableAmount(topicID, msg.sender);

        IUCV(_payrollUCVs[topicID]).transferTo(
            msg.sender,
            token,
            leftAmount,
            abi.encode("")
        );

        emit PayrollClaimed(topicID, msg.sender, leftTimes, leftAmount, token);
        _userClaims[topicID][msg.sender] += leftTimes;
    }

    /// @inheritdoc IPayrollManager
    function getClaimableAmount(bytes32 proposalID, address claimer)
        external
        view
        override
        returns (
            uint256 leftTimes,
            uint256 leftAmount,
            address token
        )
    {
        return _getClaimableAmount(proposalID, claimer);
    }

    function _getClaimableAmount(bytes32 topicID, address claimer)
        internal
        view
        returns (
            uint256 leftTimes,
            uint256 leftAmount,
            address token
        )
    {
        console.log("_getClaimableAmount:");
        console.logBytes32(topicID);

        PayrollSchedule storage schedule = _schedules[topicID];
        IProposalHandler proposalHandler = IProposalHandler(_dao);

        (bytes32 typeID, bytes memory memberBytes) = proposalHandler
            .getTopicKVdata(topicID, "members");

        PayrollScheduleMember[] memory payrollMembers = abi.decode(
            memberBytes,
            (PayrollScheduleMember[])
        );

        console.log(payrollMembers.length);

        for (uint256 i = 0; i < payrollMembers.length; i++) {
            if (payrollMembers[i].memberAddress == claimer) {
                console.log("exist #### ");

                console.log("approved times", schedule.approvedTimes);
                // is a member
                uint256 claimableTime = schedule.approvedTimes -
                    _userClaims[topicID][claimer];
                /// @dev make sure if the user has been removed, should calculate based on when he has been removed
                leftTimes = claimableTime;

                leftAmount = leftTimes * payrollMembers[i].oncePay;

                token = payrollMembers[i].token;

                break;
            }
        }
    }

    /// @inheritdoc IPayrollManager
    function getPayrollBatch(bytes32 proposalID, uint256 limit)
        external
        override
        returns (PayrollBatchInfo[] memory batchs)
    {}

    function getTypeID() external override returns (bytes32 typeID) {}

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external override returns (uint256 version) {}
}
