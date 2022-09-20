// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../base/ERC721.sol";

abstract contract SoulBoundToken is ERC721 {
    uint256 public counter;

    mapping(address => uint256) public soulBoundTokenId;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    modifier onlyOne(address _owner) {
        require(
            balanceOf[_owner] == 0,
            "SoulBoundToken: already have a soul bound token"
        );
        _;
    }

    function _mintSBT(address _to)
        internal
        virtual
        onlyOne(_to)
        returns (uint256)
    {
        uint256 tokenId = counter++;

        _safeMint(_to, tokenId);

        return tokenId;
    }
}
