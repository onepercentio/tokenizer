// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";


contract Collection {
    function getNftData(uint256 tokenId) public view returns (string memory) {}    
}

contract ProjectERC20 is Context, ERC20, IERC721Receiver {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) minterToId;

    // Initial supply = 0
    uint256 private _totalSupply = 0;

    uint8 private _decimals = 0;

    string private _name;
    string private _symbol;
    string public vintage;
    string public projectIdentifier;



    constructor (
        string memory name_, 
        string memory symbol_,
        string memory _projectIdentifier,
        string memory _vintage
        ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        projectIdentifier = _projectIdentifier;
        vintage = _vintage;
    }

    /**
     * @dev function is called with `operator` as `_msgSender()` in a reference implementation by OZ
     * `from` is the previous owner, not necessarily the same as operator
     *
     **/
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        
        external 
        override 
        returns (bytes4) 
        {
        console.log("----------------\n");
        console.log("DEBUG sol: address operator:", operator);
        console.log("DEBUG sol: address from:", from);
        console.log("DEBUG sol: address msg.sender:", msg.sender);
        console.log("DEBUG sol: address _msgSender():", _msgSender());

        require(checkWhiteListed(msg.sender), "Error: Batch-NFT not from whitelisted contract");
        require(checkMatchingAttributes(msg.sender, tokenId), "Error: non-matching NFT");

        minterToId[from] = tokenId;
        return this.onERC721Received.selector;

    }

    // Check if BatchCollection is whitelisted (official)
    function checkWhiteListed(address collection) internal view returns (bool) {
    }

    /**
     * @dev Checks if attributes of sent NFT are matching the attributes of this ERC20
     *  @param collection is the address of the ERC721 collection the NFT was sent from
     *  @param tokenId is the tokenId that shall be checked
     **/
    function checkMatchingAttributes(address collection, uint256 tokenId) internal view returns (bool) {
        console.log("DEBUG sol: _checkMatchingAttributes called");
        console.log(Collection(collection).getNftData(tokenId));
        console.log(vintage);

        bytes32 pid721 = keccak256(abi.encodePacked(Collection(collection).getNftData(tokenId)));
        bytes32 pid20 = keccak256(abi.encodePacked(projectIdentifier));

        if (pid20 == pid721) { 
            return true;
        }
        else {
            return false;
        }
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
