// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title CoolNFTWhiteList
 * @author @fankcoder
 */
contract CoolNFTWhiteList {
    event WhitelistSaleConfigChanged(WhitelistSaleConfig config);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public baseTokenURI;
    // set NFT max supply 
    uint256 public constant MAX_TOKEN = 10000;

    // set white list config
    struct WhitelistSaleConfig {
        bytes32 merkleRoot;
        uint256 startTime;
        uint256 endTime; 
    }
    WhitelistSaleConfig public whitelistSaleConfig;
    mapping(address => bool) public whitelistClaimed;

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
        require(isWhitelistSaleEnabled(), "whitelist sale has not enabled");
        require(isWhitelistAddress(signature_), "caller is not in whitelist or invalid signature");
        require(whitelistClaimed[msg.sender] == false, "Already Mint");
        require(_tokenIds.current()<= MAX_TOKEN, "max supply exceeded");
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
    }

   /**
     * @notice setWhitelistSaleConfig is used to set the configuration related to whitelist sale.
     * This process is under the supervision of the community.
     * @param config_ config
     */
    function setWhitelistSaleConfig(WhitelistSaleConfig calldata config_) external onlyOwner {
        whitelistSaleConfig = config_;
        emit WhitelistSaleConfigChanged(config_);
    }

    /**
     * @notice isWhitelistSaleEnabled is used for check whitelist sale.
     */
    function isWhitelistSaleEnabled() public view returns (bool) {
        if (whitelistSaleConfig.endTime > 0 && block.timestamp > whitelistSaleConfig.endTime) {
            return false;
        }
        return whitelistSaleConfig.startTime > 0 && 
            block.timestamp > whitelistSaleConfig.startTime &&
            mintPrice[0] > 0 &&
            whitelistSaleConfig.merkleRoot != "";
    }

    /**
     * @notice isWhitelistAddress is used to verify whether the sender address and signature_ belong to merkleRoot.
     * @param signature_ merkle proof
     */
    function isWhitelistAddress(bytes32[] calldata signature_) public view returns (bool) {
        if (whitelistSaleConfig.merkleRoot == "") {
            return false;
        }
        return MerkleProof.verify(
                signature_,
                whitelistSaleConfig.merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            );
    }

}
