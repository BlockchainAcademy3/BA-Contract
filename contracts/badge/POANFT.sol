// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../base/ERC721.sol";

contract POANFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 public counter;

    string public baseURI;

    mapping(uint256 => uint256) public eventIds;

    mapping(uint256 => uint256) public expiryForEvents;

    event BaseURIChanged(string oldURI, string newURI);

    event POANFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed eventId
    );

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    modifier notExpiry(uint256 _eventId) {
        uint256 expiryDate = expiryForEvents[_eventId];
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

    function mint(address _to, uint256 _eventId)
        public
        notExpiry(_eventId)
        returns (uint256)
    {
        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        // Record this token's course Id
        eventIds[tokenId] = _eventId;

        emit POANFTMinted(_to, tokenId, _eventId);

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
        return string.concat(baseURI, eventIds[_tokenId].toString());
    }
}
