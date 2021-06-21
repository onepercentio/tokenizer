// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IContractRegistry.sol";
import "hardhat/console.sol";

contract ProjectContract is ERC721, Ownable {

    using Counters for Counters.Counter;

    event ProjectMinted(address sender, string purpose);

    Counters.Counter private _tokenIds;
    address public contractRegistry;


    constructor() public ERC721("ProjectCollection", "Offset-Projects") {}

    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }


    function mintProject(address to, string memory tokenURI)
        public
        returns (uint256)
    {

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting to ", to);
        console.log("newItemId is ", newItemId);
        _mint(to, newItemId);
        // _setTokenURI(newItemId, tokenURI);
        emit ProjectMinted(to, tokenURI);
        return newItemId;
    }
}
