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
    function checkWhiteListed(address erc20Addr) internal view returns (bool) {
        uint16 v = ProjectERC20(erc20Addr).vintage();
        string memory r = ProjectERC20(erc20Addr).region();
        string memory std = ProjectERC20(erc20Addr).standard();
        string memory m = ProjectERC20(erc20Addr).methodology();

        bool vMatch = false;
        bool rMatch  = false;
        bool stdMatch  = false;
        bool mMatch  = false; 
        
        // Length of struct array
        uint256 setLen = allowedSets.length;

        // Here: For loop, looping through set array
        // for (uint i = 0; i < setLen-1; i++) {
        // ...

        uint256 vlen = allowedSets[0].vintages.length;
        uint256 rlen = allowedSets[0].regions.length;

        for (uint i = 0; i < vlen-1; i++) {
            if (allowedSets[0].vintages[i]==v) {
                vMatch = true;
                break;
            }
            else {
                continue;
            }
        }
        
        for (uint i = 0; i < rlen-1; i++) {
            if (keccak256(abi.encodePacked(allowedSets[0].regions[i]))==keccak256(abi.encodePacked(r))) {
                rMatch = true;
                break;
            }
            else {
                continue;
            }
        }
        

        // Final check if all attributes are matching
        if (vMatch && rMatch && stdMatch && mMatch) return true;
        else return false;

    }

}
