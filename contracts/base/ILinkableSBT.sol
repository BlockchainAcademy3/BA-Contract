// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ILinkableSBT {
    function onERC721Linked(
        address from,
        uint256 fromTokenId,
        address to,
        uint256 toTokenId
    ) external returns (bytes4);
}
