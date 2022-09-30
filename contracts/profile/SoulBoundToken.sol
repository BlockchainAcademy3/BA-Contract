// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../base/ERC721Upgradeable.sol";

abstract contract SoulBoundToken is ERC721Upgradeable {
    uint256 public counter;

    mapping(address => uint256) public soulBoundTokenId;

    function __SBT_init(string memory _name, string memory _symbol)
        internal
        onlyInitializing
    {
        __ERC721_init(_name, _symbol);
    }

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

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override {
        require(
            _from == ZERO_ADDRESS || _to == ZERO_ADDRESS,
            "SBT: No transfers"
        );
    }
}
