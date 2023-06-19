// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PunkNFT is ERC721, Ownable {
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 private mintedTokens;

    constructor() ERC721("PunkNFT", "PNFT") {
        mintedTokens = 0;
        for (uint i = 0; i < 100; i++) {
            uint256 randomIndex = uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.difficulty, i)
                )
            ) % MAX_SUPPLY;

            if (!_exists(randomIndex)) {
                _mint(msg.sender, randomIndex);
                mintedTokens++;
            }
        }
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        require(tokenId < MAX_SUPPLY, "Token ID exceeds maximum supply");
        require(!_exists(tokenId), "Token ID is already taken");
        require(mintedTokens < MAX_SUPPLY, "Max supply reached");
        _mint(to, tokenId);
        mintedTokens++;
    }
}
