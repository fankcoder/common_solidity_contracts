// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CoolNFT
 * @author @fankcoder
 */
contract CoolNFT is ERC721URIStorage, ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public baseTokenURI;
    // set NFT max supply 
    uint256 public constant MAX_TOKEN = 10000;

    constructor() ERC721("CoolNFT", "CNFT") {
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
     * @notice mint is used to mint nft. 
     */
    function mint() public {
        require(_tokenIds.current()<= MAX_TOKEN, "max supply exceeded");
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
    }

}
