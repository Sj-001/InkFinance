//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IIdentity.sol";
import "hardhat/console.sol";

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
contract IdentityManager is IIdentity {
    address public immutable _kycManager;

    mapping(address => KVZone) private _zoneKeyValues;

    constructor(address kycManager_) {
        _kycManager = kycManager_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IIdentity).interfaceId;
    }

    /// @inheritdoc IIdentity
    function batchSetUserKVs(UserKV[] memory kvs) external override {
        // must be KYCVerifier
        require(msg.sender == _kycManager, "Not allowed to set user info");
        address zone = msg.sender;
        KVZone storage kvZone = _zoneKeyValues[zone];
        for (uint256 i = 0; i < kvs.length; i++) {
            Value memory v;
            v.typeID = kvs[i].typeID;
            v.data = kvs[i].data;
            kvZone.kvs[kvs[i].user][kvs[i].key] = v;
        }
    }

    /// @inheritdoc IIdentity
    function getUserKV(
        address zone,
        address user,
        string memory key
    ) external view override returns (bytes32 typeID, bytes memory data) {
        KVZone storage kvZone = _zoneKeyValues[zone];
        return (kvZone.kvs[user][key].typeID, kvZone.kvs[user][key].data);
    }
}
