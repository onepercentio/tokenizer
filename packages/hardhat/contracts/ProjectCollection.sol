// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IContractRegistry.sol";

import "./IProjectCollection.sol";


contract ProjectCollection is IProjectCollection, ERC721, Ownable {
    using Counters for Counters.Counter;

    event ProjectMinted(address sender, string purpose);

    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    // MetaData could contain attributes like dates, country, region, standard etc.
    struct ProjectData {
        string projectId;
        string standard;
        string methodology;
        string region;
        string metaDataHash;
        string tokenURI;
        address controller; // could be a multisig that can change project data
    }


    mapping (uint256 => ProjectData) public projects;

    // Mapping all projectIds for uniqueness check
    mapping (string => bool) public projectIds;

    mapping (string => uint) public pidToTokenId;


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
        string memory projectId,
        string memory standard,
        string memory methodology,
        string memory region,
        string memory metaDataHash,
        string memory tokenURI
        )
        public override
        returns (uint256)
    {
        require(projectIds[projectId]==false, "Project already exists");
        projectIds[projectId] = true;
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        // console.log("DEBUG sol: minting Project NFT to ", to);
        // console.log("DEBUG sol: newItemId is ", newItemId);
        _mint(to, newItemId);

        projects[newItemId].projectId = projectId;
        projects[newItemId].methodology = methodology;
        projects[newItemId].standard = standard;
        projects[newItemId].region = region;     
        projects[newItemId].metaDataHash = metaDataHash;
        projects[newItemId].tokenURI = tokenURI;

        // _setTokenURI(newItemId, tokenURI);
        emit ProjectMinted(to, tokenURI);
        pidToTokenId[projectId] = newItemId;
        return newItemId;
    }

    function removeProject(uint tokenId) public onlyOwner {
        delete projects[tokenId];
    }

    // Retrieve all data from ProjectNFT struct
    function getProjectDataByTokenId(uint256 tokenId) public view
        returns (string memory, string memory, string memory, string memory, string memory, string memory) 
        {
         return (
            projects[tokenId].projectId,
            projects[tokenId].methodology,
            projects[tokenId].standard,
            projects[tokenId].region,
            projects[tokenId].metaDataHash,
            projects[tokenId].tokenURI
         );     
    }

        // Retrieve data from ProjectNFT relevant for pools
        function getProjectDataByProjectId(string memory projectId) public view
        returns (string memory, string memory, string memory) 
        {
         uint tokenId = pidToTokenId[projectId];   
         return (
            projects[tokenId].standard,
            projects[tokenId].methodology,
            projects[tokenId].region
         );     
    }

}
