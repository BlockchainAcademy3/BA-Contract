// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title ERC721 Token Contract
 *
 * @notice This contract is mainly based on solmate/ERC721.sol
 *         By default, not implement IERC721Metadata
 */
contract ERC721 {
    address internal constant ZERO_ADDRESS = address(0);

    string public name;
    string public symbol;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function approve(address _spender, uint256 _tokenId) public virtual {
        address owner = ownerOf[_tokenId];

        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "NOT_AUTHORIZED"
        );

        getApproved[_tokenId] = _spender;

        emit Approval(owner, _spender, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        public
        virtual
    {
        isApprovedForAll[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        _beforeTokenTransfer(from, to, id);

        require(from == ownerOf[id], "WRONG_FROM");

        require(to != ZERO_ADDRESS, "INVALID_RECIPIENT");

        require(
            msg.sender == from ||
                isApprovedForAll[from][msg.sender] ||
                msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            --balanceOf[from];

            ++balanceOf[to];
        }

        ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);

        _afterTokenTransfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function _mint(address to, uint256 id) internal virtual {
        require(to != ZERO_ADDRESS, "INVALID_RECIPIENT");

        require(ownerOf[id] == ZERO_ADDRESS, "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            ++balanceOf[to];
        }

        ownerOf[id] = to;

        emit Transfer(ZERO_ADDRESS, to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(owner != ZERO_ADDRESS, "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            --balanceOf[owner];
        }

        delete ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, ZERO_ADDRESS, id);
    }

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    address(0),
                    id,
                    ""
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    address(0),
                    id,
                    data
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}
}
