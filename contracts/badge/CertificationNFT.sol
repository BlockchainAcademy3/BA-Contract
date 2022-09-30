// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../base/ERC721Upgradeable.sol";

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
    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __Ownable_init();
        __ERC721_init(_name, _symbol);
    }
}
