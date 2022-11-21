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
     * @notice mint is used for mint CT.
     * @param amount specify mint count, 1 amount equal 1 ether.
     */
    function mint(address _addr, uint256 amount) external onlyOwner {
        _mint(_addr, amount*10**18);
    }


    /**
    * @notice Airdrop is used for aridrop token to address.
    * @param addrs specify mint count, 1 amount equal 1 ether.
    * @param amounts specify mint count, 1 amount equal 1 ether.
    */
    function Airdrop(address[] memory addrs, uint256[] memory amounts) external onlyOwner {
        for (uint i = 0; i < addrs.length; ++i) {
            mint(addrs[i], amounts[i]);
        }
    }
}