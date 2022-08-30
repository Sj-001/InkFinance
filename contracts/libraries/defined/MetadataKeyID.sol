//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// used in metadata reverse key.
library MetadataKeyID {
    // keccak256("md.TOPIC_ID")
    bytes32 internal constant TOPIC_ID =
        0x8f06fbfe274a235ecfd3493b7b68d0057074f0181721b69b37e85aa71bb1c01f;

    // keccak256("md.GOVERNANCE_TOKEN")
    bytes32 internal constant GOVERNANCE_TOKEN =
        0x2b14b96420d43c57c8d3eacfb2ac199ac1820f65b71ea83ed13810ea176f9804;
}
