// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/ERC721Upgradeable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Certification NFT for Blockchain Academy
 * @author Eric Lee
 *
 * @notice This contract is used to mint NFTs for Blockchain Academy Certification.
 *
 *         Certification is the top level NFT for Blockchain Academy.
 *         It is minted for those who:
 *         - Complete all BuidlCamp courses and exercises
 *         - Finish certain courses combination & pass certain tests
 *         - To be extended...
 *
 *         Certification NFT is a ERC721 token.
 *
 */
contract CertificationNFT is OwnableUpgradeable, ERC721Upgradeable {
    using Strings for uint256;

    uint256 counter;

    string public baseURI;

    // Token id => Certification id
    mapping(uint256 => uint256) certificationIds;

    // User address => certification id => token id
    mapping(address => mapping(uint256 => uint256)) public userMinted;

    event BaseURIChanged(string oldURI, string newURI);

    event CertificationNFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed certificationId
    );

    event CertificaitonNFTBurned(
        uint256 indexed tokenId,
        uint256 indexed certificationId
    );

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __Ownable_init();
        __ERC721_init(_name, _symbol);
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        emit BaseURIChanged(_uri, baseURI);
        baseURI = _uri;
    }

    function mint(address _to, uint256 _certificationId)
        external
        onlyOwner
        returns (uint256)
    {
        require(
            userMinted[_to][_certificationId] == 0,
            "CertificationNFT: already minted"
        );

        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        certificationIds[tokenId] = _certificationId;

        userMinted[_to][_certificationId] = tokenId;

        emit CertificationNFTMinted(_to, tokenId, _certificationId);

        return tokenId;
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf[_tokenId] == msg.sender,
            "Only the token owner can burn"
        );

        _burn(_tokenId);

        uint256 certificationId = certificationIds[_tokenId];
        delete userMinted[msg.sender][certificationId];

        emit CertificaitonNFTBurned(_tokenId, certificationId);
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
        return string.concat(baseURI, certificationIds[_tokenId].toString());
    }
}
