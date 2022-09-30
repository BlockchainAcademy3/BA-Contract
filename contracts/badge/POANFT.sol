// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../base/ERC721Upgradeable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Proof-of-Attendance NFT
 *
 * @notice This contract is used to mint NFTs for Proof-of-Attendance events.
 *
 *         Event is identified by a unique event ID. Event details are stored on server.
 *
 *         Token URI = Base URI + Event Id
 *         E.g.
 *           Token id 2 and 5 are both for event 1, then
 *           tokenURI(2) = tokenURI(5) = "https://api.web3edu.xyz/poa/1
 */
contract POANFT is OwnableUpgradeable, PausableUpgradeable, ERC721Upgradeable {
    using Strings for uint256;

    uint256 public counter;

    string public baseURI;

    // Token id => Event Id
    mapping(uint256 => uint256) public eventIds;

    // Event id => Expiry date
    mapping(uint256 => uint256) public expiryForEvents;

    event BaseURIChanged(string oldURI, string newURI);

    event POANFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed eventId
    );

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __Ownable_init();
        __Pausable_init();
        __ERC721_init(_name, _symbol);
    }

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
