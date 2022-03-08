// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// contract for a merkle tree with functions that allow the tree to be modified and verified
contract MerkleTree {
    mapping(uint32 => bytes32) public node; bytes32 public root; uint32 public depth; uint32 public nextLeaf; uint32 internal endDepth;

    // constructs Merkle Tree with depth as parameter
    constructor(uint32 _depth) {depth = _depth; endDepth = uint32(2)**depth;}

    // add leaf to merkle tree
    function addLeaf(bytes32 leaf) internal {
        require(nextLeaf != endDepth, "You have gone past the depth of the Merkle Tree");
        node[nextLeaf] = leaf; updateTree(nextLeaf); nextLeaf++;
    }

    // recalculate hashes after merkle tree is modified
    function updateTree(uint32 addedLeaf) internal {
        uint32 index = addedLeaf; uint32 dist; bytes32 left; bytes32 right; uint32 nodeDepth; 

        for (uint32 i = 0; i < depth; i++) {
            if (nextLeaf % 2 == 0) {
                left = node[index];
                right = node[index+1];
            } else {
                left = node[index-1];
                right = node[index];
            }

            nodeDepth = index - dist;
            dist += uint32(2)**i;
            index = nodeDepth / 2 + dist;
            node[index] = keccak256(abi.encodePacked(left, right));
        }
        root = node[index]; 
    }
}
