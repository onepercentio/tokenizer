// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract BatchContract is ERC721, Ownable {
    event BatchMinted(address sender, string purpose);

    constructor() ERC721("ClaimCollection", "v0.1-Claim") {}

    address public contractRegistry;

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
        return newItemId;
    }
}
