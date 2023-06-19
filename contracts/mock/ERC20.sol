// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Punk is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 200000000 * (10 ** 18);

    constructor() ERC20("Punk", "PUNK") {
        _mint(msg.sender, 100000000 * (10 ** 18));
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Minting will exceed max supply"
        );
        _mint(to, amount);
    }
}
