//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IUCV is IERC165 {
    event Transfer(address to, uint256 value, bytes data, uint256 txGas);

    event UCVManagerDisabled(bool disabled);

    function transfer(
        address to,
        uint256 value,
        bytes memory data,
        uint256 txGas
    ) external returns (bool success);

    function disableUCVManager(bool disable) external;
}
