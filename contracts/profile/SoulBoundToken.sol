// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../base/ERC721.sol";

contract SoulBoundToken is ERC721 {
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}
}
