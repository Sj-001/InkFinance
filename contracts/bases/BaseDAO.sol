//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IDAO.sol";
import "../interfaces/IDeploy.sol";

import "./BaseVerify.sol";

abstract contract BaseDAO is IDeploy, IDAO, BaseVerify {
    // libs
    using EnumerableSet for EnumerableSet.AddressSet;

    struct StepLinkInfo {
        address committee;
        bytes32 nextStep;
        uint256 sensitive;
    }

    // @dev the one who created the DAO
    address ownerAddress;

    string name;
    string describe;
    IERC20 govToken;
    uint256 govTokenAmountRequirement;
    address stakingAddr;

    uint256 public constant MAX_STEP_NUM = 10;

    bytes32 internal constant _SENTINEL_ID =
        0x0000000000000000000000000000000000000000000000000000000000000001;

    /// @dev key is dutyID
    /// find duty members according to dutyID,
    mapping(uint256 => EnumerableSet.AddressSet) private _dutyMembers;

    // process category flow ID => (stepID => step info)
    mapping(bytes32 => mapping(bytes32 => StepLinkInfo)) internal _flowSteps;

    function init(
        address admin,
        address addrRegistry,
        bytes calldata data
    ) public virtual override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IDAO
    function addDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDAO
    function remmoveDuty(bytes32 dutyID) external override {}

    /// @inheritdoc IDAO
    function addUser(address account) external override {}

    /// @inheritdoc IDAO
    function removeUser(address account) external override {}

    /// @inheritdoc IDAO
    function hasDuty(address account, bytes32 dutyID)
        external
        override
        returns (bool exist)
    {}

    /// @inheritdoc IDAO
    function getDutyOwners(bytes32 dutyID)
        external
        override
        returns (uint256 owners)
    {}

    /// @inheritdoc IDAO
    function getDutyOwnerByIndex(bytes32 dutyID, uint256 index)
        external
        override
        returns (address addr)
    {}

    /// Agent Related
    // 获取该DAO中, 该agentID对应的代理地址.
    function getAgentIDAddr(bytes32 agentID)
        external
        override
        returns (address addr)
    {}

    // 指定proposalID, 并且最多执行多少个agent.
    function continueExec(bytes32 proposalID, uint256 agentNum)
        external
        override
    {}

    // 不检查agentID是否存在, 直接映射即可.
    // 仅能自己调用自己.
    function setAgentFlowID(bytes32 agentID, bytes32 flowID)
        external
        override
    {}

    function getAgentFlowID(bytes32 agentID)
        external
        override
        returns (bytes32 flowID)
    {}

    function execTx(TxInfo[] memory txs) external override {}

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
        returns (Proposal memory proposal)
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
