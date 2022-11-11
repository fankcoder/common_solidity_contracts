// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CoolToken
 * @author @fankcoder
 */
contract CoolToken is ERC20, Ownable {

    constructor() ERC20("CoolToken", "CT") {
    }

    /**
     * @notice mint is used for mint SVT.
     * @param amount specify mint count.
     */
    function mint(uint256 amount) external onlyOwner {
        _mint(minter, amount);
    }
}