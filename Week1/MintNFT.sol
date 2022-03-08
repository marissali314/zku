// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
// tokenURI comes from here
import "@openzeppelin/contracts@4.5.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";

// written supplementary merkle tree file 
import "./MerkleTree.sol";

/// @title Open mint of ERC721 tokens @author Merzz
contract MintNFT is ERC721, ERC721URIStorage, MerkleTree {
    using Counters for Counters.Counter; Counters.Counter private _tokenIds;

    mapping(uint256 => bytes) private _tokenURIs;

    // constructor for the NFT
    constructor(string memory name, string memory sym, uint32 treeDepth) 
    ERC721(name, sym) MerkleTree(treeDepth) {}

    // overrides the necessary contracts
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage){
        super._burn(tokenId);
    }

    // sets the token metadata
    function _setTokenURI(uint256 tokenId, bytes memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    // mints the NFT on chain
    function mint(address receiver, string memory name, string memory description) public {
        uint256 tokenId = _tokenIds.current(); _tokenIds.increment(); _mint(receiver, tokenId);

        bytes memory metaData = abi.encodePacked(
            "{", name, description ,"}"
        );

        _setTokenURI(tokenId, metaData);
        addLeaf(keccak256(abi.encodePacked(msg.sender, receiver, tokenId, metaData)));
    }

    // returns the metadata of the NFT
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        require(_exists(tokenId), "Token does not exist");
        return string(_tokenURIs[tokenId]);
    }
}
