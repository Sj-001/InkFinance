//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseVerify.sol";

import "../interfaces/IUCV.sol";

error OperateIsNowAllowed();

contract InkUCV is IUCV, BaseVerify {
    address private _ucvController;
    address private _ucvManager;
    bool private _ucvManagerEnable;

    /// @dev make sure msgSender is controller or manager, and manager has to be allow to do all the operation
    modifier enableToExecute() {
        if (
            _msgSender() != _ucvController &&
            (_msgSender() == _ucvManager && _ucvManagerEnable == true)
        ) revert OperateIsNowAllowed();
        _;
    }

    modifier onlyController() {
        if (_msgSender() != _ucvController) revert OperateIsNowAllowed();
        _;
    }

    function init(
        address admin,
        address config,
        bytes calldata data
    ) external override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IUCV
    function transfer(
        address to,
        uint256 value,
        bytes memory data,
        uint256 txGas
    ) external override enableToExecute returns (bool success) {}

    /// @inheritdoc IUCV
    function enableUCVManager(bool enable_) external override onlyController {
        _ucvManagerEnable = enable_;
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
