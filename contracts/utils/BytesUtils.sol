//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BytesUtils {
    function toAddress(bytes memory self) internal pure returns (address addr) {
        assembly {
            addr := mload(add(self, 20))
        }

        //addr = abi.decode(self, (address));
    }

    function toBytes32(bytes memory self) internal pure returns (bytes32) {
        bytes32 targetBytes32;

        assembly {
            targetBytes32 := mload(add(self, 32))
        }
        return targetBytes32;
    }
}
