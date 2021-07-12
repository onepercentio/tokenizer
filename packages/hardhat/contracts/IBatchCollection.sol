// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IBatchCollection {

    function getProjectIdent(uint256 tokenId) external view returns (string memory);

    function getQuantity(uint256 tokenId) external view returns (uint);   

    function getConfirmationStatus(uint256 tokenId) external view returns (bool);

    function getBatchNFTData(uint256 tokenId) external view returns (string memory, uint16, string memory, uint, bool);
}
