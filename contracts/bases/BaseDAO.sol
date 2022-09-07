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
