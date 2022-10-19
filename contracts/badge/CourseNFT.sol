// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/ERC721Upgradeable.sol";
import "../base/Linkable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CourseNFT is OwnableUpgradeable, ERC721Upgradeable, Linkable {
    using Strings for uint256;

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Variables **************************************** //
    // ---------------------------------------------------------------------------------------- //

    uint256 public counter;

    string public baseURI;

    // Token id => Course Id
    // Course id is an index for the server to query the course
    // After querying the correct course, the server can get the event data
    mapping(uint256 => uint256) public courseIds;

    // Expiry timestamp for a course id
    // After this timestamp, the NFT is no longer available for mint
    // If expiry == 0, the NFT is always available for mint
    mapping(uint256 => uint256) public expiryForCourses;

    // User address => course id => token id
    mapping(address => mapping(uint256 => uint256)) public userMinted;

    // ---------------------------------------------------------------------------------------- //
    // *************************************** Events ***************************************** //
    // ---------------------------------------------------------------------------------------- //

    event BaseURIChanged(string oldURI, string newURI);

    event CourseNFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed courseId
    );

    event CourseNFTBurned(uint256 indexed tokenId, uint256 indexed courseId);

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Constructor ************************************** //
    // ---------------------------------------------------------------------------------------- //

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __Ownable_init();
        __ERC721_init(_name, _symbol);
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Modifiers *************************************** //
    // ---------------------------------------------------------------------------------------- //

    modifier notExpired(uint256 _courseId) {
        uint256 expiryDate = expiryForCourses[_courseId];
        if (expiryDate != 0) {
            require(
                block.timestamp < expiryDate,
                "CourseNFT: NFT is no longer available for mint"
            );
        }
        _;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Set Functions ************************************* //
    // ---------------------------------------------------------------------------------------- //

    function setBaseURI(string memory _uri) public onlyOwner {
        emit BaseURIChanged(_uri, baseURI);
        baseURI = _uri;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Main Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    function mint(address _to, uint256 _courseId)
        external
        notExpired(_courseId)
        onlyOwner
        returns (uint256)
    {
        require(
            userMinted[_to][_courseId] == 0,
            "CourseNFT: user already minted this course"
        );

        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        // Record this token's course Id
        courseIds[tokenId] = _courseId;

        userMinted[_to][_courseId] = tokenId;

        emit CourseNFTMinted(_to, tokenId, _courseId);

        return tokenId;
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf[_tokenId] == msg.sender,
            "Only the token owner can burn"
        );

        _burn(_tokenId);

        uint256 courseId = courseIds[_tokenId];
        delete userMinted[msg.sender][courseId];

        emit CourseNFTBurned(_tokenId, courseId);
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenURI(_tokenId);
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
        return string.concat(baseURI, courseIds[_tokenId].toString());
    }
}
