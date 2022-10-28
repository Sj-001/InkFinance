//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseVerify.sol";

import "../interfaces/IUCV.sol";
import "../utils/TransferHelper.sol";

error OperateIsNowAllowed();

contract PayrollUCV is IUCV, BaseVerify {
    address private _ucvController;
    address private _ucvManager;
    bool private _ucvManagerEnable;

    address private _dao;

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
        emit ChainTokenDeposited(msg.sender, msg.value);
    }

    modifier onlyController() {
        if (_msgSender() != _ucvController) revert OperateIsNowAllowed();
        _;
    }

    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {
        _dao = dao_;
        // _ucvController =
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
        uint256 value,
        bytes memory data
    ) external override enableToExecute returns (bool) {
        if (token != address(0x0)) {
            IERC20(token).transfer(to, value);
            // TransferHelper.safeTransfer(token, to, value);
        } else {
            payable(to).transfer(value);
        }

        return true;
    }

    /// @inheritdoc IUCV
    function enableUCVManager(bool enable_) external override onlyController {
        _ucvManagerEnable = enable_;
    }

    /// @inheritdoc IUCV
    function getManager() external view override returns (address ucvManager) {
        ucvManager = _ucvManager;
    }

    /// @inheritdoc IDeploy
    function getTypeID() external override returns (bytes32 typeID) {}

    /// @inheritdoc IDeploy
    function getVersion() external override returns (uint256 version) {}

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
}
