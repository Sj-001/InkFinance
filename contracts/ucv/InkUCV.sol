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
        address dao_,
        address config_,
        bytes calldata data_
    ) external override returns (bytes memory callbackEvent) {}

    /// @inheritdoc IUCV
    function transfer(
        address to,
        uint256 value,
        address token,
        bytes memory data,
        uint256 txGas
    ) external override enableToExecute returns (bool success) {
        if (txGas == 0) {
            // 5000 is not exact, in dev, is random.
            // TODO: fix 5000
            require(gasleft() > 5000, "gas not enough");
            txGas = gasleft() - 5000;
        }

        emit UCVTransfer(to, value, data, txGas);

        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := call(
                txGas,
                to,
                value,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
        }

        return success;
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
