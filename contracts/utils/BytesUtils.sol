//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BytesUtils {
    function toAddress(bytes memory self) internal returns (address addr) {
        assembly {
            addr := mload(add(self, 32))
        }
    }

    function toBytes32(bytes memory self) internal returns (bytes32) {
        bytes32 targetBytes32;

        assembly {
            targetBytes32 := mload(add(self, 32))
        }
        return targetBytes32;
    }
}
