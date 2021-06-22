// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract BatchCollection is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    event BatchMinted(address sender, string purpose);
    event BatchRetirementConfirmed(uint256 tokenId);
    
    address private _verifier;
    mapping (uint256 => bool) private _retirementConfirmedStatus;

    /// @dev A mapping from batch IDs to the address that owns them. All batches have
    ///  some valid owner address, assigned when minted
    mapping (uint256 => address) public batchIndexToOwner;
    
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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Returns a list of all Kitty IDs assigned to an address.
    /// @param _owner The owner whose Kitties we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Kitty array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalNfts = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all nfts have IDs starting at 1 and increasing
            // sequentially up to the totalNfts count.
            uint256 nftId;

            for (nftId = 1; nftId <= totalNfts; nftId++) {
                if (batchIndexToOwner[nftId] == _owner) {
                    result[resultIndex] = nftId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
    function mintBatchWithData(
        address to,
        string memory projectName,
        string memory vintage,
        string memory symbol,
        uint256 CO2tons)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        console.log("minting to ", to);
        console.log("newItemId is ", newItemId);
        _safeMint(to, newItemId);

        nftList[newItemId].projectName = projectName;
        nftList[newItemId].vintage = vintage;
        nftList[newItemId].symbol = symbol;
        nftList[newItemId].quantity = CO2tons;

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
        batchIndexToOwner[newItemId] = to;
        // _setTokenURI(newItemId, tokenURI);
        emit BatchMinted(to, tokenURI);
        return newItemId;
    }
}
