// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../base/ERC721Upgradeable.sol";
import "../base/Linkable.sol";
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
contract POANFT is
    OwnableUpgradeable,
    PausableUpgradeable,
    ERC721Upgradeable,
    Linkable
{
    using Strings for uint256;

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Variables **************************************** //
    // ---------------------------------------------------------------------------------------- //

    // Current token id
    uint256 public counter;

    // Base uri of the token metadata
    string public baseURI;

    // Token id => Event Id
    mapping(uint256 => uint256) public eventIds;

    // Event id => Expiry date
    mapping(uint256 => uint256) public expiryForEvents;

    // Event id => Event owner
    mapping(uint256 => address) public eventOwner;

    // User address => Event id => Token id
    mapping(address => mapping(uint256 => uint256)) userMinted;

    // ---------------------------------------------------------------------------------------- //
    // *************************************** Events ***************************************** //
    // ---------------------------------------------------------------------------------------- //

    event BaseURIChanged(string oldURI, string newURI);

    event EventOwnerChanged(
        uint256 indexed eventId,
        address oldEventOwner,
        address eventOwner
    );

    event POANFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed eventId
    );

    event POANFTBurned(uint256 tokenId, uint256 eventId);

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Constructor ************************************** //
    // ---------------------------------------------------------------------------------------- //

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __Ownable_init();
        __Pausable_init();
        __ERC721_init(_name, _symbol);
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Modifiers *************************************** //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Events should not be expired before minting
     */
    modifier notExpired(uint256 _eventId) {
        uint256 expiryDate = expiryForEvents[_eventId];
        if (expiryDate != 0) {
            require(
                block.timestamp < expiryDate,
                "CourseNFT: NFT is no longer available for mint"
            );
        }
        _;
    }

    /**
     * @notice Only permitted addresses can mint
     *
     *         Permitted:
     *         - Owner (if minted on BA website)
     *         - Event owner (if the event owner want to mint on his own website)
     */
    modifier onlyPermitted(uint256 _eventId) {
        require(
            msg.sender == owner() || msg.sender == eventOwner[_eventId],
            "CourseNFT: Only owner or event owner can mint"
        );
        _;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ View Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenURI(_tokenId);
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Set Functions ************************************* //
    // ---------------------------------------------------------------------------------------- //

    function setBaseURI(string memory _uri) external onlyOwner {
        emit BaseURIChanged(_uri, baseURI);
        baseURI = _uri;
    }

    function setEventOwner(uint256 _eventId, address _eventOwner)
        external
        onlyOwner
    {
        emit EventOwnerChanged(_eventId, eventOwner[_eventId], _eventOwner);
        eventOwner[_eventId] = _eventOwner;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Main Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    function mint(address _to, uint256 _eventId)
        external
        notExpired(_eventId)
        onlyPermitted(_eventId)
        returns (uint256)
    {
        require(
            userMinted[_to][_eventId] == 0,
            "CourseNFT: User already minted"
        );

        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        // Record this token's course Id
        eventIds[tokenId] = _eventId;

        userMinted[_to][_eventId] = tokenId;

        emit POANFTMinted(_to, tokenId, _eventId);

        return tokenId;
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf[_tokenId] == msg.sender,
            "Only the token owner can burn"
        );

        _burn(_tokenId);

        uint256 eventId = eventIds[_tokenId];
        delete userMinted[msg.sender][eventId];

        emit POANFTBurned(_tokenId, eventIds[_tokenId]);
    }

    // ---------------------------------------------------------------------------------------- //
    // *********************************** Internal Functions ********************************* //
    // ---------------------------------------------------------------------------------------- //

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
