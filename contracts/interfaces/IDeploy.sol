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

    /// @notice get the type of the contract, it's constant
    /// @param typeID type of the deployed contract
    /// @dev the most used type list here
    /// DAO: keccak256(DAOTypeID) = 0xdeb63a88d4573ec3359155ef44dd570a22acdf5208f7256d196e6bb7483d1b85;
    /// Committee: keccak256(CommitteeTypeID) = 0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;
    /// Agent: keccak256(AgentTypeID) = 0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845;
    function getTypeID() external returns (bytes32 typeID);

    /// @dev get the version of the deployed contract, it's a constant, the system could
    /// decide if we should upgrade the deployed contract according to the version.
    /// @return version the version number of the deployed contract
    function getVersion() external returns (uint256 version);
}
