// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CodeNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Mapping from token ID to code hash
    mapping(uint256 => bytes32) private _codeHashes;
    
    // Event emitted when new code is minted
    event CodeMinted(uint256 indexed tokenId, address indexed creator, bytes32 codeHash);

    constructor() ERC721("Code NFT", "CODE") {}

    /**
     * @dev Creates a new Code NFT
     * @param recipient Address that will own the NFT
     * @param tokenURI URI containing metadata about the code
     * @param codeHash Hash of the actual code being tokenized
     * @return uint256 ID of the newly minted NFT
     */
    function mintCode(
        address recipient,
        string memory tokenURI,
        bytes32 codeHash
    ) public onlyOwner returns (uint256) {
        require(codeHash != bytes32(0), "Code hash cannot be empty");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _codeHashes[newTokenId] = codeHash;
        
        emit CodeMinted(newTokenId, recipient, codeHash);
        
        return newTokenId;
    }

    /**
     * @dev Retrieves the code hash for a given token ID
     * @param tokenId The ID of the NFT
     * @return bytes32 Hash of the code associated with the NFT
     */
    function getCodeHash(uint256 tokenId) public view returns (bytes32) {
        require(_exists(tokenId), "Token does not exist");
        return _codeHashes[tokenId];
    }

    /**
     * @dev Verifies if a given code matches the hash stored in the NFT
     * @param tokenId The ID of the NFT
     * @param code The code to verify
     * @return bool True if the code matches the stored hash
     */
    function verifyCode(uint256 tokenId, string memory code) public view returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        bytes32 providedHash = keccak256(abi.encodePacked(code));
        return providedHash == _codeHashes[tokenId];
    }

    /**
     * @dev Override transfer function to add custom logic if needed
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Returns the total number of NFTs minted
     */
    function getTotalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}
