// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";

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
    address public contractRegistry;


    constructor (
        string memory name_, 
        string memory symbol_,
        string memory _projectIdentifier,
        string memory _vintage,
        address _contractRegistry
        ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        projectIdentifier = _projectIdentifier;
        vintage = _vintage;
        contractRegistry = _contractRegistry;
    }

    /**
     * @dev function is called with `operator` as `_msgSender()` in a reference implementation by OZ
     * `from` is the previous owner, not necessarily the same as operator
     *  Function checks if NFT collection is whitelisted and next if attributes are matching this erc20 contract
     **/
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external 
        override 
        returns (bytes4) 
        {
        (string memory pid, string memory vintage, string memory serialno, uint quantity, bool approved) = IBatchCollection(msg.sender).getNftData(tokenId);
        console.log("DEBUG sol:", pid, vintage, serialno);
        console.log("DEBUG sol:", quantity, approved);


        // msg.sender is the BatchCollection contract
        require(checkWhiteListed(msg.sender), "Error: Batch-NFT not from whitelisted contract");
        require(checkMatchingAttributes(msg.sender, tokenId), "Error: non-matching NFT");
        require(approved==true, "BatchNFT not yet confirmed");

        minterToId[from] = tokenId;

        _mint(from, quantity);
        return this.onERC721Received.selector;

    }

    // Check if BatchCollection is whitelisted (official)
    function checkWhiteListed(address collection) internal view returns (bool) {
        if (collection == IContractRegistry(contractRegistry).batchCollectionAddress()) {
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * @dev Checks if attributes of sent NFT are matching the attributes of this ERC20
     *  @param collection is the address of the ERC721 collection the NFT was sent from
     *  @param tokenId is the tokenId that shall be checked
     **/
    function checkMatchingAttributes(address collection, uint256 tokenId) internal view returns (bool) {
        console.log("DEBUG sol: _checkMatchingAttributes called");

        bytes32 pid721 = keccak256(abi.encodePacked(IBatchCollection(collection).getProjectIdent(tokenId)));
        bytes32 pid20 = keccak256(abi.encodePacked(projectIdentifier));

        if (pid20 == pid721) { 
            return true;
        }
        else {
            return false;
        }
    }


    // Retirement of TCUs
    function retire(uint256 amount) public {
        _retire(_msgSender(), amount);
    }

    function retireFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: retire amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
        _retire(_msgSender(), amount);
    }

    // non-functional
    function _retire(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        address retirementAddress = IContractRegistry(contractRegistry).retirementAddress();
        transfer(retirementAddress, uint256 amount)
    }


    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
