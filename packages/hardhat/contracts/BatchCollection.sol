// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract BatchCollection is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    event BatchMinted(address sender, string purpose);
    event BatchRetirementConfirmed(uint256 tokenId);
    
    address private _verifier;
    mapping (uint256 => bool) private _retirementConfirmedStatus;

    
    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    struct NFTData {
        string projectIdentifier;
        string vintage;
        string serialNumber;
        uint256 quantity;
        bool approved;
    }

    mapping (uint256 => NFTData) public nftList;

    constructor() ERC721("ClaimCollection", "v0.1-Claim") {}

    //onlyOwner
    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }

    modifier onlyVerifier() {
        require(_verifier == _msgSender(), "BatchCollection: caller is not the owner");
        _;
    }

    function confirmRetirement (uint256 tokenId) public onlyVerifier {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        _retirementConfirmedStatus[tokenId] = true;
        emit BatchRetirementConfirmed(tokenId);
    }

    function getNftData(uint256 tokenId) public view returns (string memory) {
        return nftList[tokenId].projectIdentifier;
    }

    // here for debugging/mock purposes. safeTransferFrom(...) is error prone with ethers.js
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        
        console.log("\n--------------");
        console.log("DEBUG sol: called transferFrom(): msg.sender:", msg.sender);
        console.log("DEBUG sol:", from, to, tokenId);
        console.log("DEBUG sol: address of CO2KenNFTCollection", address(this));
        
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        // _transfer(from, to, tokenId);
        safeTransferFrom(from, to, tokenId, "");
    }


    function ownerBalanceOf(address owner) public view returns (uint256) {
        uint256 balance = balanceOf(owner);
        console.log("Owner balance is ", balance);

        return (balance);
    }


    function mintBatchWithData(
        address to,
        string memory _projectIdentifier,
        string memory _vintage,
        string memory _serialNumber,
        uint256 quantity)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting to ", to);
        console.log("newItemId is ", newItemId);
        _safeMint(to, newItemId);

        nftList[newItemId].projectIdentifier = _projectIdentifier;
        nftList[newItemId].vintage = _vintage;
        nftList[newItemId].serialNumber = _serialNumber;
        nftList[newItemId].quantity = quantity;
        nftList[newItemId].approved = false;
        
        return newItemId;
    }


    function mintBatch(address to, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting to ", to);
        console.log("newItemId is ", newItemId);
        _safeMint(to, newItemId);

        emit BatchMinted(to, tokenURI);
        return newItemId;
    }
}
