// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title CoolNFTByUsdt
 * @author @fankcoder
 */
contract CoolNFTByUsdt is ERC721URIStorage, ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public baseTokenURI;
    
    // set mint price in USDT (注意：USDT通常是6位小数)
    uint256 public price = 100 * 10**6; // 100 USDT (假设USDT是6位小数)
    
    // USDT合约地址
    IERC20 public usdtToken;

    // set NFT max supply 
    uint256 public constant MAX_TOKEN = 10000;

    constructor(address _usdtTokenAddress) ERC721("CoolNFT", "CNFT") {
        require(_usdtTokenAddress != address(0), "Invalid USDT address");
        usdtToken = IERC20(_usdtTokenAddress);
    }

    // 更新USDT合约地址
    function setUsdtToken(address _usdtTokenAddress) external onlyOwner {
        require(_usdtTokenAddress != address(0), "Invalid USDT address");
        usdtToken = IERC20(_usdtTokenAddress);
    }

    // 更新铸造价格（以USDT的最小单位表示）
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function transfer(address _address, uint256 tokenId) external {
        _safeTransfer(msg.sender, _address, tokenId, "");
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal onlyOwner override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
  
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
  
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
  
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory uri) external virtual onlyOwner {
        baseTokenURI = uri;
    }

    /**
     * @notice mint is used to mint nft with USDT
     */
    function mint() external {
        require(_tokenIds.current() < MAX_TOKEN, "max supply exceeded");
        
        // 检查USDT授权和余额
        uint256 tokenId = _tokenIds.current() + 1;
        uint256 amount = price;
        
        require(usdtToken.allowance(msg.sender, address(this)) >= amount, "Insufficient USDT allowance");
        require(usdtToken.balanceOf(msg.sender) >= amount, "Insufficient USDT balance");
        
        // 转账USDT到合约
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "USDT transfer failed");
        
        // 铸造NFT
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
    }

    /**
     * @notice 提取合约中的USDT
     */
    function withdrawUSDT(address to) external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");
        require(usdtToken.transfer(to, balance), "USDT transfer failed");
    }

    /**
     * @notice 获取当前铸造价格（以USDT显示）
     */
    function getPrice() external view returns (uint256) {
        return price;
    }

    /**
     * @notice 获取当前总供应量
     */
    function totalSupply() public view override returns (uint256) {
        return _tokenIds.current();
    }
}