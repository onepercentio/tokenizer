// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IProjectCollection {
    // function vintageCount(string calldata) external view returns (uint256);

    function addNewProject(
        address to,
        string memory _projectIdentifier,
        string memory _methodology,
        string memory _standard,
        string memory _region,
        string memory _metaDataHash,
        string memory _tokenURI
        )
        external returns (uint256);

    function getProjectData(uint256 tokenId) external view 
        returns (string memory, string memory, string memory, string memory);

    // function ownerOf(uint256) external view returns (address);
}
