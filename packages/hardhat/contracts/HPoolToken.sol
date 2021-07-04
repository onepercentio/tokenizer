// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";

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
        string[] memory _vintages,
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

    // Wrapper for external functions
    function approveExternal(address erc20Addr, address spender, uint amount) public {
        IERC20(erc20Addr).approve(spender, amount);
    } 

    function deposit(address erc20Addr, uint amount) public {
        // transfers token from sender (current owner) to this contract
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), amount);

        // mints pool/index token to prev. owner(sender)
        _mint(msg.sender, amount);
    }

    // Checks if an ERC20 contract is whitelisted
    function checkWhiteListed(address erc20Addr) internal view returns (bool) {
        uint v = IERC20(erc20Addr).vintage;
        string memory r = IERC20(erc20Addr).region;
        string memory std = IERC20(erc20Addr).standard;
        string memory m = IERC20(erc20Addr).methodology;


    }

}
