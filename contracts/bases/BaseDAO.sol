//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";
import "../interfaces/IFactoryManager.sol";

import "./BaseVerify.sol";

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;

    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
        uint256 sensitive;
    }

    // variables
    // constant
    uint256 public constant MAX_STEP_NUM = 10;

    bytes32 internal constant _SENTINEL_ID =
        0x0000000000000000000000000000000000000000000000000000000000000001;

    // @dev the one who created the DAO
    address private ownerAddress;
    string private name;
    string private describe;
    IERC20 private govToken;
    uint256 private govTokenAmountRequirement;
    address private stakingAddr;

    /// @dev key is dutyID
    /// find duty members according to dutyID,
    mapping(bytes32 => EnumerableSet.AddressSet) private _dutyMembers;

    /// @notice how many dutyIDs the EOA address have in the DAO
    /// @dev once the _dutyCounts become 0, it should be removed from the DAO
    mapping(address => uint256) private _dutyCounts;

    // process category flow ID => (stepID => step info)
    mapping(bytes32 => mapping(bytes32 => StepLinkInfo)) internal _flowSteps;

    function init(
        address admin,
        address addrRegistry,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IDutyControl
    function addDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function remmoveDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDutyControl
    function addUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function removeUser(address account) external override {}

    /// @inheritdoc IDutyControl
    function hasDuty(address account, bytes32 dutyID)
        external
        override
        returns (bool exist)
    {
        exist = _hasDuty(account, dutyID);
    }

    function _hasDuty(address account, bytes32 dutyID)
        internal
        returns (bool exist)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwners(bytes32 dutyID)
        external
        override
        returns (uint256 owners)
    {}

    /// @inheritdoc IDutyControl
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        override
        returns (address addr)
    {}

    // which proposal decide the latest key item;
    function getTopicKeyProposal(bytes32 topicID, bytes32 key)
        external
        view
        override
        returns (bytes32 proposalID)
    {}

    function getTopicMetadata(bytes32 topicID, bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getTopicInfo(bytes32 topicID)
        external
        view
        override
        returns (Topic memory topic)
    {}

    //////////////////// proposal

    function getProposalSummary(bytes32 proposalID)
        external
        view
        override
        returns (ProposalSummary memory proposal)
    {}

    function getProposalMetadata(bytes32 proposalID, bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getProposalKvData(bytes32 proposalID, bytes32 key)
        external
        view
        override
        returns (bytes32 typeID, bytes memory data)
    {}

    function getProposalKvDataKeys(
        bytes32 proposalID,
        bytes32 startKey,
        uint256 pageSize
    ) external view override returns (bytes32[] memory keys) {}

    //////////////////// flush index
    // dao查看该topicID上次刷新到的位置(lastIndexedProposalID, lastIndexedKey), 来继续进行, 所以权限问题.
    function flushTopicIndex(bytes32 topicID, uint256 operateNum)
        external
        override
    {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IDAO).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    modifier EnsureGovEnough() {
        require(
            govToken.balanceOf(ownerAddress) > govTokenAmountRequirement,
            "admin's gov not enough"
        );
        _;
    }
}
