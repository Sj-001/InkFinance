//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IDeploy is IERC165 {
    // init for deploy and just do once time.
    function init(
        address admin,
        address config,
        bytes calldata data
    ) external returns (bytes memory callbackEvent);
}
