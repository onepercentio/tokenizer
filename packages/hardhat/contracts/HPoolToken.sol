// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";
import "./ProjectERC20.sol";


contract HPoolToken is Context, ERC20, Ownable {

    // Initial supply = 0
    uint256 public _totalSupply = 0;

    // Describes the allowe attributes as arrays per set
    // Note: pids (project identifiers) probably not needed
    struct  AttributeSet {
        uint16[] vintages;
        string[] regions;
        string[] standards;
        string[] methodologies;
        // string[] pids;
    }

    // All allowed sets
    AttributeSet[] allowedSets;

    constructor(string memory name_, string memory _symbol) ERC20(name_, _symbol) {}


    // Function to create new AttributeSets and add them to allowedSets
    function addAttributeSet(
        uint16[] memory _vintages,
        string[] memory _regions,
        string[] memory _standards,
        string[] memory _methodologies
        ) public onlyOwner {
        AttributeSet memory set;

        set.vintages = _vintages;
        set.regions = _regions;
        set.standards = _standards;
        set.methodologies = _methodologies;

        allowedSets.push(set);
    }


    // Shall give the owner the ability to remove certain attribute sets
    function removeAttributeSet(uint index) public onlyOwner {
        delete allowedSets[index];
    }


    // Wrapper for external functions to approve token pre-deposit
    function approveExternal(address erc20Addr, address spender, uint amount) public {
        IERC20(erc20Addr).approve(spender, amount);
    } 

    function deposit(address erc20Addr, uint amount) public {
        // transfers token from sender (current owner) to this contract
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), amount);

        // mints pool/index token to prev. owner(sender)
        _mint(msg.sender, amount);
    }

    // Checks whether incoming pERC20 token matches the accepted criteria/attributes 
    function checkAttributeMatching(address erc20Addr) internal view returns (bool) {

        // Querying the attributes from the incoming pERC20 token
        uint16 v = ProjectERC20(erc20Addr).vintage();
        string memory r = ProjectERC20(erc20Addr).region();
        string memory s = ProjectERC20(erc20Addr).standard();
        string memory m = ProjectERC20(erc20Addr).methodology();

        // Corresponding match variables
        bool vMatch = false;
        bool rMatch  = false;
        bool sMatch  = false;
        bool mMatch  = false; 
        
        // Length of struct array
        uint256 setLen = allowedSets.length;

        // Here: For loop, looping through set array
        for (uint x = 0; x < setLen-1; x++) {
        
            // Every array might have a different length
            uint256 vlen = allowedSets[x].vintages.length;
            uint256 rlen = allowedSets[x].regions.length;
            uint256 slen = allowedSets[x].standards.length;
            uint256 mlen = allowedSets[x].standards.length;

            for (uint i = 0; i < vlen-1; i++) {
                if (allowedSets[x].vintages[i]==v) {
                    vMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            for (uint i = 0; i < rlen-1; i++) {
                if (keccak256(abi.encodePacked(allowedSets[x].regions[i]))==keccak256(abi.encodePacked(r))) {
                    rMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            for (uint i = 0; i < slen-1; i++) {
                if (keccak256(abi.encodePacked(allowedSets[x].standards[i]))==keccak256(abi.encodePacked(s))) {
                    sMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            for (uint i = 0; i < mlen-1; i++) {
                if (keccak256(abi.encodePacked(allowedSets[x].methodologies[i]))==keccak256(abi.encodePacked(m))) {
                    mMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            // Final check if all attributes are matching
            if (vMatch && rMatch && sMatch && mMatch) return true;
            else continue;
        }
        // no matches found during search
        return false;
    }

}
