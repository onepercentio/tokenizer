// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

import "./IContractRegistry.sol";

contract BatchCollection is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address;

    event BatchMinted(address sender, string serialNumber, uint quantity);

    event BatchRetirementConfirmed(uint256 tokenId);
    
    address private _verifier;

    /// @dev A mapping from batchs IDs to the address that owns them. All batches have
    ///  some valid owner address from the point of minting, then transfer
    mapping (uint256 => address) public batchIndexToOwner;

    address public contractRegistry;
    Counters.Counter private _tokenIds;

    // WIP: The fields and naming is subject to change
    // required: projectIdentifier+vintage+serialNumber = unique
    struct NFTData {
        string projectIdentifier;
        string vintage;
        string serialNumber;
        uint256 quantity;
        bool confirmed;
    }

    mapping (uint256 => NFTData) public nftList;

    constructor(address _contractRegistry) ERC721("ClaimCollection", "v0.1-Claim") {
        contractRegistry = _contractRegistry;
    }


    // The verifier has the authority to confirm NFTs so ERC20's can be minted
    modifier onlyVerifier() {
        require(_verifier == _msgSender(), "BatchCollection: caller is not the owner");
        _;
    }   

    // Simple setter for verifier, there shall be multiple ones
    function setVerifier (address verifier) public onlyOwner {
        _verifier = verifier;
    }

    // Appointed verifier confirms that claim about retirement is valid 
    function confirmRetirement (uint256 tokenId) public onlyVerifier {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        nftList[tokenId].confirmed = true;
        emit BatchRetirementConfirmed(tokenId);
    }

    function getProjectIdent(uint256 tokenId) public view returns (string memory) {
        return nftList[tokenId].projectIdentifier;
    }

    function getQuantity(uint256 tokenId) public view returns (uint) {
        return nftList[tokenId].quantity;
    }

    function getConfirmationStatus(uint256 tokenId) public view returns (bool) {
        return nftList[tokenId].confirmed;
    }

   function getNftData(uint256 tokenId) public view returns (string memory, string memory, string memory, uint, bool) {
        return (
            nftList[tokenId].projectIdentifier,
            nftList[tokenId].vintage,
            nftList[tokenId].serialNumber,
            nftList[tokenId].quantity,
            nftList[tokenId].confirmed
            );
    }

    // here for debugging/mock purposes. safeTransferFrom(...) is error prone with ethers.js
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {       
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        safeTransferFrom(from, to, tokenId, "");
    }


    function ownerBalanceOf(address owner) public view returns (uint256) {
        uint256 balance = balanceOf(owner);
        console.log("Owner balance is ", balance);

        return (balance);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC721, ERC721Enumerable) {
        console.log("DEBUG sol: called _beforeTokenTransfer");
        console.log(contractRegistry);
        if (to.isContract()) {
        require(IContractRegistry(contractRegistry).checkERC20(to), "pERC20 contract is not official");
        }
        else {
            super._beforeTokenTransfer(from, to, amount);
        }

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Returns a list of all BatchIDs assigned to an address.
    function tokensOfOwner(address _owner) external view returns(NFTData[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) 
        {
            // Return an empty array
            return new NFTData[](0);
        } 
        else 
        {
            NFTData[] memory result = new NFTData[](tokenCount);
            uint256 totalNfts = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all nfts have IDs starting at 1 and increasing
            // sequentially up to the totalNfts count.
            uint256 nftId;

            for (nftId = 1; nftId <= totalNfts; nftId++) {
                if (batchIndexToOwner[nftId] == _owner) {
                    result[resultIndex] = nftList[nftId];
                    resultIndex++;
                }
            }

            return result;
        }
    }

    // Entry function to bring offsets on-chain
    // Mints an NFT claiming that 1 to n tons have been retired
    // On mint confirmation status is set to fale
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
        console.log("minting Batch NFT to ", to);
        console.log("newItemId is ", newItemId);
        batchIndexToOwner[newItemId] = to;

        _safeMint(to, newItemId);
        emit BatchMinted(to, _serialNumber, quantity);

        nftList[newItemId].projectIdentifier = _projectIdentifier;
        nftList[newItemId].vintage = _vintage;
        nftList[newItemId].serialNumber = _serialNumber;
        nftList[newItemId].quantity = quantity;
        nftList[newItemId].confirmed = false;
        
        return newItemId;
    }

}
