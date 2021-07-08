// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IContractRegistry.sol";
import "hardhat/console.sol";

contract ProjectCollection is ERC721, Ownable {
    using Counters for Counters.Counter;

    event ProjectMinted(address sender, string purpose);

    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    // MetaData could contain attributes like dates, country, region, standard etc.
    struct ProjectData {
        string projectIdentifier;
        string metaDataHash;
        string tokenURI;
        address controller; // could be a multisig that can change project data
    }

    mapping (uint256 => ProjectData) public projects;


    constructor() ERC721("ProjectCollection", "Offset-Projects") {}

    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }


    function mintProject(
        address to,
        string memory _projectIdentifier,
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

        projects[newItemId].projectIdentifier = _projectIdentifier;
        projects[newItemId].metaDataHash = _metaDataHash;
        projects[newItemId].tokenURI = _tokenURI;

        // _setTokenURI(newItemId, tokenURI);
        emit ProjectMinted(to, _tokenURI);
        return newItemId;
    }
}
