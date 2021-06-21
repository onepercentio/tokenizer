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

    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    struct NFTData {
        string projectName;
        string vintage;
        string symbol;
        uint256 quantity;
        bool approved;
    }

    mapping (uint256 => NFTData) public nftList;

    constructor() ERC721("ClaimCollection", "v0.1-Claim") {}

    //onlyOwner
    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }


    function getNftData(uint256 tokenId) public view returns (string memory) {
        return nftList[tokenId].vintage;
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


    function mintBatch(address to, string memory tokenURI)
        public
        returns (uint256)
    {
        // console.log(
        //     "projectFactoryAddress is ",
        //     IContractRegistry(contractRegistry).projectFactoryAddress()
        // );
        // require(
        //     msg.sender ==
        //         IContractRegistry(contractRegistry).projectFactoryAddress()
        // );
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting to ", to);
        console.log("newItemId is ", newItemId);
        _safeMint(to, newItemId);

        // // This needs different function parameters
        // nftList[newItemId].projectName = projectName;
        // nftList[newItemId].vintage = vintage;
        // nftList[newItemId].symbol = symbol;
        // nftList[newItemId].quantity = CO2tons;

        // _setTokenURI(newItemId, tokenURI);
        emit BatchMinted(to, tokenURI);
        return newItemId;
    }
}
