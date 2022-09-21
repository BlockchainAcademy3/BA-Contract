// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../base/ERC721.sol";

contract CourseNFT is Ownable, ERC721 {
    using Strings for uint256;

    uint256 public counter;

    // Token id => Course Id
    // Course id is an index for the server to query the course
    // After querying the correct course, the server can get the event data
    mapping(uint256 => uint256) public courseIds;

    // Expiry timestamp for a course id
    // After this timestamp, the NFT is no longer available for mint
    // If expiry == 0, the NFT is always available for mint
    mapping(uint256 => uint256) public expiryForCourses;

    string public baseURI;

    event BaseURIChanged(string oldURI, string newURI);

    event CourseNFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed courseId
    );

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    modifier notExpiry(uint256 _courseId) {
        uint256 expiryDate = expiryForCourses[_courseId];
        if (expiryDate != 0) {
            require(
                block.timestamp < expiryDate,
                "CourseNFT: NFT is no longer available for mint"
            );
        }
        _;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        emit BaseURIChanged(_uri, baseURI);
        baseURI = _uri;
    }

    function mint(address _to, uint256 _courseId)
        public
        notExpiry(_courseId)
        returns (uint256)
    {
        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        // Record this token's course Id
        courseIds[tokenId] = _courseId;

        emit CourseNFTMinted(_to, tokenId, _courseId);

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
