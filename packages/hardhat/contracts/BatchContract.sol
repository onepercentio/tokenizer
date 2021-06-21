// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract BatchContract is ERC721, Ownable {
    address private _verifier;

    event BatchMinted(address sender, string purpose);
    event BatchRetirementConfirmed(uint256 tokenId);

    constructor() public ERC721("Carbon Retirement Batch", "CRB") {}
    
    address public contractRegistry;
    // Once offchain retirement has been confirmed
    mapping (uint256 => bool) private _retirementConfirmedStatus;
    //uint256[] private _retirementUnConfirmed;

    // function getUnretired(uint256 tokenId) public view returns (uint256[]) {
    //     return _retirementConfirmedStatus; //mapping
    // }

    
    /**
     * @dev Throws if called by any account other than the verifier.
     */
    modifier onlyVerifier() {
        require(_verifier == _msgSender(), "BatchContract: caller is not the owner");
        _;
    }

    function confirmRetirement (uint256 tokenId) public onlyVerifier {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        _retirementConfirmedStatus[tokenId] = true;
        emit BatchRetirementConfirmed(tokenId);
        // remove tokenId form this array - _retirementUnConfirmed
        // emit Approval(ownerOf(tokenId), to, tokenId);
    }

    //onlyOwner
    function setContractRegistry(address _address) public onlyOwner {
        contractRegistry = _address;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using SafeMath for uint256;

    function ownerBalanceOf(address owner) public view returns (uint256) {
        uint256 balance = balanceOf(owner);
        console.log("Owner balance is ", balance);

        //https://github.com/pipermerriam/ethereum-string-utils
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
        _mint(to, newItemId);
        // _setTokenURI(newItemId, tokenURI);
        emit BatchMinted(to, tokenURI);
        _retirementConfirmedStatus[newItemId] = false;
        //_retirementUnConfirmed.push(newItemId);
        return newItemId;
    }
}
