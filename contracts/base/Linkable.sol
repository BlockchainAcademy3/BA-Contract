// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ILinkableSBT.sol";

abstract contract Linkable {
    // Token id => Keccak256(contract, id)
    mapping(uint256 => bytes32) public links;

    /**
     * @notice Ensure that this tokenId not already linked
     */
    modifier notLinked(uint256 _tokenId) {
        require(
            links[_tokenId] == bytes32(0),
            "Linkable: token already linked to another sbt"
        );
        _;
    }

    /**
     * @notice Link a token to a SoulBoundToken
     *
     *         The target token address must be a soul-bound token
     *         It should check the target has the interface
     */
    function _link(
        address _sbt,
        uint256 _targetTokenId,
        uint256 _tokenId
    ) internal virtual notLinked(_tokenId) {
        links[_tokenId] = keccak256(abi.encodePacked(_sbt, _targetTokenId));

        require(
            _sbt.code.length != 0 &&
                ILinkableSBT(_sbt).onERC721Linked(
                    address(this),
                    _tokenId,
                    _sbt,
                    _targetTokenId
                ) ==
                ILinkableSBT.onERC721Linked.selector,
            "UNSAFE_LINK"
        );
    }
}
