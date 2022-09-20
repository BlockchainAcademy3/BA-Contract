// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../base/ERC721.sol";

contract CourseNFT is ERC721 {
    uint256 public counter;

    // Expiry timestamp
    // After this timestamp, the NFT is no longer available for mint
    // If expiry == 0, the NFT is always available for mint
    uint256 public expiry;

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

    function mint(address _to) public notExpiry returns (uint256) {
        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        return tokenId;
    }

}
