// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // dev & testing

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";

contract HPoolToken is Context, ERC20, Ownable {

    // Initial supply = 0
    uint256 public _totalSupply = 0;

    struct AttributeSet {
        string[] vintages;
        string[] region;
        string[] standard;
        string[] pids;
    }

    function addAttributeSet(
        string[] memory vintages,
        string[] memory region,
        string[] memory standard,
        string[] memory pids
        ) public onlyOwner {

    }

    constructor(string memory name_, string memory _symbol) ERC20(name_, _symbol) {}

    // Checks if an ERC20 contract is whitelisted
    function checkWhiteListed(address collection) internal view onlyOwner returns (bool) {
    }


}
