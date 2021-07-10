// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IContractRegistry.sol";

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

    // Mapping all projectIds for uniqueness check
    mapping (string => bool) public projectIds;


    constructor() ERC721("ProjectCollection", "Offset-Projects") {}

    // Note: Not sure if this function is really necessary
    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }

    // Updates the controller, the entity in charge of the ProjectData
    // Note: Questionable if needed if this stays ERC721, as this could be the NFT owner
    function updateController(uint tokenId, address _controller) public {
        require(msg.sender==ownerOf(tokenId), "Error: Caller is not the owner");
        projects[tokenId].controller = _controller;
    }

    // Adding is currently permissionless
    // updating will require permission 
    function addNewProject(
        address to,
        string memory _projectId,
        string memory _methodology,
        string memory _standard,
        string memory _region,
        string memory _metaDataHash,
        string memory _tokenURI
        )
        public 
        returns (uint256)
    {
        require(projectIds[_projectId]==false, "Project already exists");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        // console.log("DEBUG sol: minting Project NFT to ", to);
        // console.log("DEBUG sol: newItemId is ", newItemId);
        _mint(to, newItemId);

        projects[newItemId].projectId = _projectId;
        projects[newItemId].methodology = _methodology;
        projects[newItemId].standard = _standard;
        projects[newItemId].region = _region;     
        projects[newItemId].metaDataHash = _metaDataHash;
        projects[newItemId].tokenURI = _tokenURI;

        // _setTokenURI(newItemId, tokenURI);
        emit ProjectMinted(to, _tokenURI);
        return newItemId;
    }

    function removeProject(uint tokenId) public onlyOwner {
        delete projects[tokenId];
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
