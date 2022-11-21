// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Cool1155 is ERC1155 {
    uint256 public constant BAYC = 0;
    uint256 public constant Punk = 1;
    uint256 public constant Azuki = 2;


    constructor() public ERC1155("https://example/api/item/{id}.json") {
        _mint(msg.sender, BAYC, 1, "");
        _mint(msg.sender, Punk, 1, "");
        _mint(msg.sender, Azuki, 1, "");
    }
}