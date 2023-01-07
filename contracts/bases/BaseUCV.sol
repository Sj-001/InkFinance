//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../bases/BaseVerify.sol";

import "../interfaces/IUCV.sol";
import "../utils/TransferHelper.sol";
import "hardhat/console.sol";
error OperateIsNowAllowed();
error DepositeError();
error TokenTypeNotSupport(uint256 tokenType);

abstract contract BaseUCV is IUCV, BaseVerify {
    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    /// @dev token = address(0) means chain gas token
    event VaultDeposit(
        address indexed dao,
        address indexed token,
        address indexed to,
        uint256 tokenType,
        uint256 tokenID,
        string itemName,
        uint256 depositeAmount,
        address depositer,
        string depositDesc,
        uint256 depositeTime
    );

    address private _ucvController;
    address private _ucvManager;
    bool private _ucvManagerEnable;

    address private _dao;

    mapping(address => EnumerableSet.UintSet) private ownedNFTs;

    /// @dev make sure msgSender is controller or manager, and manager has to be allow to do all the operation
    modifier enableToExecute() {
        if (
            _msgSender() != _ucvController &&
            (_msgSender() == _ucvManager && _ucvManagerEnable == true)
        ) revert OperateIsNowAllowed();
        _;
    }

    event ChainTokenDeposited(address sender, uint256 amount);

    receive() external payable {
        // emit ChainTokenDeposited(msg.sender, msg.value);
    }

    fallback() external payable {}

    modifier onlyController() {
        if (_msgSender() != _ucvController) revert OperateIsNowAllowed();
        _;
    }

    function _init(
        address dao_,
        address config_,
        address ucvManager_,
        address ucvController_
    ) internal returns (bytes memory callbackEvent) {
        _dao = dao_;
        _ucvManager = ucvManager_;
        _ucvController = ucvController_;
    }

    function setUCVManager(address ucvManager_) external override {
        if (msg.sender != _dao) {
            revert OperateIsNowAllowed();
        }
        _ucvManager = ucvManager_;
    }

    /// @inheritdoc IUCV
    function transferTo(
        address to,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 value,
        bytes memory data
    ) external override enableToExecute returns (bool) {
        return _transferTo(to, token, tokenType, tokenID, value, data);
    }


    function _transferTo(
        address to,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 value,
        bytes memory data
    ) internal returns (bool) {
        if (tokenType == 721) {
            IERC721(token).safeTransferFrom(address(this), to, tokenID, "");
        } else if (tokenType == 20) {
            if (token != address(0x0)) {
                IERC20(token).transfer(to, value);
                // TransferHelper.safeTransfer(token, to, value);
            } else {
                payable(to).transfer(value);
            }
        } else {
            revert TokenTypeNotSupport(tokenType);
        }

        if (Address.isContract(to)) {
            if (IUCV(to).supportsInterface(type(IUCV).interfaceId)) {
                emit VaultDeposit(
                    _dao,
                    token,
                    to,
                    tokenType,
                    tokenID,
                    "deposit",
                    value,
                    address(this),
                    "",
                    block.timestamp
                );
            }
        }

        return true;
    }


    function _depositeERC20(address token, uint256 amount) internal {
        if (token == address(0)) {
            if (amount != msg.value) {
                revert DepositeError();
            }
        } else {
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }
    }

    function _depositeERC721(address token, uint256 tokenID) internal {
        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenID, "");
    }

    /// @inheritdoc IUCV
    function depositToUCV(
        string memory incomeItem,
        address token,
        uint256 tokenType,
        uint256 tokenID,
        uint256 amount,
        string memory remark
    ) external payable override {
        if (tokenType == 20) {
            _depositeERC20(token, amount);
        } else if (tokenType == 721) {
            _depositeERC721(token, tokenID);
        } else {
            revert TokenTypeNotSupport(tokenType);
        }

        emit VaultDeposit(
            _dao,
            token,
            address(this),
            tokenType,
            tokenID,
            incomeItem,
            amount,
            msg.sender,
            remark,
            block.timestamp
        );
    }

    /// @inheritdoc IUCV
    function enableUCVManager(bool enable_) external override onlyController {
        _ucvManagerEnable = enable_;
    }

    /// @inheritdoc IUCV
    function getManager() external view override returns (address ucvManager) {
        ucvManager = _ucvManager;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IUCV).interfaceId ||
            interfaceId == type(IDeploy).interfaceId;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
