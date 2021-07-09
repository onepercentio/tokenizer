// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IContractRegistry.sol";
import "./ProjectCollection.sol";

contract ProjectCollection is ERC721, Ownable {
    using Counters for Counters.Counter;

    event ProjectMinted(address sender, string purpose);

    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    // MetaData could contain attributes like dates, country, region, standard etc.
    struct ProjectData {
        string projectId;
        string methodology;
        string standard;
        string region;
        string metaDataHash;
        string tokenURI;
        address controller; // could be a multisig that can change project data
    }

    mapping (uint256 => ProjectData) public projects;


    constructor() ERC721("ProjectCollection", "Offset-Projects") {}

    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }

    // Updates the controller, the entity in charge of the ProjectData
    // Questionable if needed if this stays ERC721, as this could be the NFT owner
    function updateController(uint tokenId, address _controller) public {
        require(msg.sender==ownerOf(tokenId), "Error: Caller is not the owner");
        projects[tokenId].controller = _controller;
    }

    function addNewProject(
        address to,
        string memory _projectIdentifier,
        string memory _methodology,
        string memory _standard,
        string memory _region,
        string memory _metaDataHash,
        string memory _tokenURI
        )
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting Project NFT to ", to);
        console.log("newItemId is ", newItemId);
        _mint(to, newItemId);

        projects[newItemId].projectId = _projectIdentifier;
        projects[newItemId].methodology = _methodology;
        projects[newItemId].standard = _standard;
        projects[newItemId].region = _region;     
        projects[newItemId].metaDataHash = _metaDataHash;
        projects[newItemId].tokenURI = _tokenURI;

        // _setTokenURI(newItemId, tokenURI);
        emit ProjectMinted(to, _tokenURI);
        return newItemId;
    }

    function getProjectData(uint256 tokenId) public view
        returns (string memory, string memory, string memory, string memory) 
        {
         return (
            projects[tokenId].projectId,
            projects[tokenId].methodology,
            projects[tokenId].standard,
            projects[tokenId].region
         );     
    }

}
