// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../base/ERC721.sol";

contract CourseNFT is Ownable, ERC721 {
    using Strings for uint256;

    uint256 public counter;

    // Expiry timestamp
    // After this timestamp, the NFT is no longer available for mint
    // If expiry == 0, the NFT is always available for mint
    uint256 public expiry;

    // Token id => Course Id
    // Course id is an index for the server to query the course
    // After querying the correct course, the server can get the event data
    mapping(uint256 => uint256) public courseIds;

    string public baseURI;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _expiry
    ) ERC721(_name, _symbol) {
        expiry = _expiry;
    }

    modifier notExpiry() {
        if (expiry != 0) {
            require(
                block.timestamp < expiry,
                "CourseNFT: NFT is no longer available for mint"
            );
        }
        _;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function mint(address _to) public notExpiry returns (uint256) {
        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        return tokenId;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenURI(_tokenId);
    }

    /**
     * @notice Generate the token URI
     *
     *         Token URI will be stored on backend
     *         URI = "https://api.blockchainacademy.org/api/v1/nft/course/{courseId}"
     */
    function _tokenURI(uint256 _tokenId) internal view returns (string memory) {
        return string.concat(baseURI, courseIds[_tokenId].toString());
    }
}
