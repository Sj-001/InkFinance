//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

import "../cores/BaseVerify.sol";
import "../library/LEnumerableMetadata.sol";
import "../library/LChainLink.sol";

/// @title IdentityManager
/// @author InkTech <tech-support@inkfinance.xyz>
/// @notice IdenetityManager is used to verify the account.
contract IdentityManager is BaseVerify {
    using Address for address;
    using LEnumerableMetadata for LEnumerableMetadata.MetadataSet;
    using LChainLink for LChainLink.Link;

    struct CoinInfoOut {
        bytes32 chainID;
        string name;
        address coinAddr;
    }

    struct CoinInfo {
        bytes32 chainID;
        string name;
    }

    // key is coin addr
    struct AccountCoin {
        // address addr;

        CoinInfo info;
        LChainLink.Link link;
    }

    // key is user addr.
    struct VerifyAccount {
        // address user;

        // coin addr => coin
        mapping(address => AccountCoin) coins;
        LEnumerableMetadata.MetadataSet metadata;
        LChainLink.Link link;
    }

    //////////////////// constant

    //////////////////// local storage

    mapping(address => VerifyAccount) private _accounts;

    //////////////////// event

    event EAddAccount(address indexed user);

    event EMessage(address indexed from, bytes data);

    //////////////////// modifier
    modifier MustHaveAccount(address user) {
        require(isExistAccount(user), "account not exist");
        _;
    }

    //////////////////// constructor & init

    constructor(address addrRegistry) {
        super.init(addrRegistry);

        _accounts[LChainLink.SENTINEL_ADDR].link._init();
    }

    //////////////////// public read
    function isExistAccount(address user) public view returns (bool) {
        /* if (LChainLink._isEmpty(user)){ */
        /*   return false; */
        /* } */

        VerifyAccount storage account = _accounts[user];
        if (account.link._isEmpty()) {
            return false;
        }

        return true;
    }

    function getAccounts(address startUser, uint256 pageSize)
        public
        view
        returns (address[] memory users)
    {
        users = new address[](pageSize);

        if (LChainLink._isEmpty(startUser)) {
            startUser = LChainLink.SENTINEL_ADDR;
        }

        uint256 idx = 0;
        address currentUser = _accounts[startUser].link._getNextAddr();
        while (idx < pageSize && !LChainLink._isEmpty(currentUser)) {
            users[idx] = currentUser;

            currentUser = _accounts[currentUser].link._getNextAddr();
            idx++;
        }

        assembly {
            mstore(users, idx)
        }

        return users;
    }

    function getAccountCoins(
        address user,
        address startCoin,
        uint256 pageSize
    ) public view MustHaveAccount(user) returns (CoinInfoOut[] memory infos) {
        VerifyAccount storage account = _accounts[user];
        infos = new CoinInfoOut[](pageSize);

        if (LChainLink._isEmpty(startCoin)) {
            startCoin = LChainLink.SENTINEL_ADDR;
        }

        uint256 idx = 0;
        address currentCoin = account.coins[startCoin].link._getNextAddr();
        while (idx < pageSize && !LChainLink._isEmpty(currentCoin)) {
            AccountCoin storage coin = account.coins[currentCoin];

            infos[idx].chainID = coin.info.chainID;
            infos[idx].name = coin.info.name;
            infos[idx].coinAddr = currentCoin;

            currentCoin = coin.link._getNextAddr();
            idx++;
        }

        assembly {
            mstore(infos, idx)
        }

        return infos;
    }

    function isAccountCoinExist(address user, address coin)
        public
        view
        returns (bool)
    {
        if (!isExistAccount(user)) {
            return false;
        }

        if (_accounts[user].coins[coin].link._isEmpty()) {
            return false;
        }

        return true;
    }

    function getAccountAllMetadata(
        address user,
        string memory startKey,
        uint256 pageSize
    ) public view MustHaveAccount(user) returns (bytes[] memory data) {
        return _accounts[user].metadata._getAll(startKey, pageSize);
    }

    function getAccountMetadata(address user, string memory key)
        public
        view
        MustHaveAccount(user)
        returns (bytes32 typeID, bytes memory data)
    {
        return _accounts[user].metadata._getByKey(key);
    }

    function encodeKvData(
        string calldata k,
        bytes32 typeID,
        bytes calldata v
    ) public pure returns (bytes memory data) {
        return abi.encode(k, typeID, v);
    }

    function decodeKvData(bytes calldata kvData)
        public
        pure
        returns (
            string memory,
            bytes32 typeID,
            bytes memory data
        )
    {
        return abi.decode(kvData, (string, bytes32, bytes));
    }

    //////////////////// user public write
    function sendMessage(bytes calldata data)
        public
        MustHaveAccount(_msgSender())
    {
        emit EMessage(_msgSender(), data);
    }

    function register() public {
        _addAccount(_msgSender());
    }

    //////////////////// admin public write
    function addAccount(address user) public IsSysAdmin {
        _addAccount(user);
    }

    // kvData[i] = abi.encode(string key, bytes32 typeID, bytes data)
    function setMetadata(address user, bytes[] calldata kvData)
        public
        IsSysAdmin
        MustHaveAccount(user)
    {
        VerifyAccount storage account = _accounts[user];
        account.metadata._setBytesSlice(kvData);
    }

    function addCoin(
        address user,
        address coinAddr,
        bytes32 chainID,
        string memory name
    ) public IsSysAdmin MustHaveAccount(user) {
        require(!LChainLink._isEmpty(coinAddr), "coin addr empty");

        VerifyAccount storage account = _accounts[user];

        AccountCoin storage coin = account.coins[coinAddr];
        require(coin.link._isEmpty(), "coin already exist");

        coin.info.chainID = chainID;
        coin.info.name = name;

        AccountCoin storage sentinel = account.coins[LChainLink.SENTINEL_ADDR];
        coin.link._addItemLink(
            sentinel.link,
            account.coins[sentinel.link._getNextAddr()].link,
            coinAddr
        );
    }

    function delCoin(address user, address coinAddr)
        public
        IsSysAdmin
        MustHaveAccount(user)
    {
        require(!LChainLink._isEmpty(coinAddr), "coin addr empty");

        VerifyAccount storage account = _accounts[user];
        AccountCoin storage coin = account.coins[coinAddr];

        require(!coin.link._isEmpty(), "account coin is empty");
        coin.link._delItemLink(
            account.coins[coin.link._getPreAddr()].link,
            account.coins[coin.link._getNextAddr()].link
        );

        delete account.coins[coinAddr];
    }

    //////////////////// private
    function _addAccount(address user) private {
        require(!isExistAccount(user), "account already exist");
        require(!user.isContract(), "account can't is contract");

        VerifyAccount storage account = _accounts[user];
        VerifyAccount storage sentinel = _accounts[LChainLink.SENTINEL_ADDR];

        account.coins[LChainLink.SENTINEL_ADDR].link._init();
        account.metadata._init();

        account.link._addItemLink(
            sentinel.link,
            _accounts[sentinel.link._getNextAddr()].link,
            user
        );

        emit EAddAccount(user);
    }
}
