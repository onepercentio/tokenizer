// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

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

    string public projectId;

    // Attributes relevant for harmonizer pools
    uint16 public vintage;
    string public region = "BR";
    string public standard = "VCS";
    string public methodology = "XYZbla";

    address public contractRegistry;

    constructor (
        string memory name_, 
        string memory symbol_,
        string memory _projectId,
        uint16 _vintage,
        address _contractRegistry
        ) ERC20(name_, symbol_) {
        projectId = _projectId;
        vintage = _vintage;
        contractRegistry = _contractRegistry;
    }

    //     constructor (
    //     string memory name_, 
    //     string memory symbol_,
    //     string memory _projectId,
    //     uint16 _vintage,
    //     string memory _region,
    //     string memory _standard,
    //     string memory _methodology,
    //     address _contractRegistry
    //     ) ERC20(name_, symbol_) {
    //     projectId = _projectId;

    //     vintage = _vintage;
    //     region = _region;
    //     standard = _standard;
    //     methodology = _methodology;
        
    //     contractRegistry = _contractRegistry;
    // }

    function getAttributes() public view returns (uint16, string memory, string memory, string memory) {
        console.log("DEBUG: getAttributes", region, standard, methodology);
        return (
            vintage,
            region,
            standard,
            methodology
        );
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
        (string memory pid, uint16 vintage, string memory serialno, uint quantity, bool approved) = IBatchCollection(msg.sender).getNftData(tokenId);
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
        bytes32 pid20 = keccak256(abi.encodePacked(projectId));

        if (pid20 == pid721) { 
            return true;
        }
        else {
            return false;
        }
    }
}
