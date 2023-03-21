//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

import "./KYCVerifyManager.sol";
import "../interfaces/IIdentity.sol";

/// @title KYCVerifyManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice KYCVerifyManager is used to verify signature
contract KYCVerifyManager {
    /// @dev when user has been verified, this event will be emit
    /// @param issuer who verified the user, eg: INK_FINANCE_KYC
    /// @param accountType eg: twitter
    /// @param account the account value, phone or email or username, etc.
    /// @param data extra data for the verified like on-chain hash & url link to describe the kyc
    event KYCVerified(
        string issuer,
        address userWallet,
        string accountType,
        string account,
        string data
    );

    using ECDSA for bytes32;

    address private _signer;

    address private _identityManager;

    mapping(bytes32 => uint256) private valiedSign;

    // uint256
    constructor(address signer_) {
        // _identityManager = identity_;
        _signer = signer_;
    }

    function getSigner() external returns (address signer) {
        signer = _signer;
    }

    function updateIdentityManager(address identityManager_) external {
        _identityManager = identityManager_;
    }

    function getIdentityManager()
        external
        view
        returns (address identityManager)
    {
        identityManager = _identityManager;
    }

    // 0xf46B1E93aF2Bf497b07726108A539B478B31e64C
    function verifyUser(
        bytes memory signature,
        string memory zone,
        string memory accountType,
        string memory account,
        string memory data /*, address testWallet */
    ) external {
        address wallet = msg.sender;
        // wallet = 0x779a3944CFbFB32038726307E48658719efaC02f;
        // wallet = testWallet;
        bytes32 signData = keccak256(
            abi.encodePacked(zone, accountType, account, wallet, data)
        );
        address actualSigner = _getSigner(signature, signData);

        require(valiedSign[signData] == 0, "The user is already verified");
        require(actualSigner == _signer, "Signature is not corret");

        valiedSign[signData] = 1;

        UserKV[] memory kvs = new UserKV[](1);
        kvs[0].key = "account_info";
        kvs[0].user = wallet;
        kvs[0].typeID = keccak256("account_info");
        kvs[0].data = abi.encode(accountType, account, data);

        IIdentity(_identityManager).batchSetUserKVs(zone, kvs);

        emit KYCVerified(zone, wallet, accountType, account, data);
        
    }

    function _getSigner(bytes memory signature, bytes32 data)
        internal
        pure
        returns (address signer)
    {
        return data.toEthSignedMessageHash().recover(signature);
    }
}
