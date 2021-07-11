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

    address public contractRegistry;

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

    constructor(string memory name_, string memory _symbol, address _contractRegistry) ERC20(name_, _symbol) {
        contractRegistry = _contractRegistry;
    }


    // Function to add a single AttributeSet to allowedSets
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


    function deposit(address erc20Addr, uint amount) public {
        // Verifiy that pERC20 is official token
        require(IContractRegistry(contractRegistry).checkERC20(erc20Addr)==true, "pERC20 not official");
        
        require(checkAttributeMatching(erc20Addr)==true, "The token sent is not accepted");
        console.log("DEBUG deposit");

        // transfers token from sender (current owner) to this contract
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), amount);

        // mints pool/index token to prev. owner(sender)
        _mint(msg.sender, amount);
    }

    // Redeem for underlying
    function redeem(uint amount) public {}

    // Redeem, and call offset on underlying contracts
    function offset(uint amount) public {}


    // Checks whether incoming pERC20 token matches the accepted criteria/attributes 
    function checkAttributeMatching(address erc20Addr) public view returns (bool) {

        console.log("DEBUG checkAttributeMatching:", erc20Addr);

        // Querying the attributes from the incoming pERC20 token
        uint16 v = ProjectERC20(erc20Addr).vintage();
        string memory s = ProjectERC20(erc20Addr).standard();
        string memory m = ProjectERC20(erc20Addr).methodology();
        string memory r = ProjectERC20(erc20Addr).region();

        // console.log("DEBUG vintage,standard:", v, s);
        // console.log("DEBUG method, region:", m, r);

        // Corresponding match variables
        bool vMatch = false;
        bool rMatch  = false;
        bool sMatch  = false;
        bool mMatch  = false; 
        
        // Length of struct array
        uint256 setLen = allowedSets.length;

        // Here: For loop, looping through set array
        for (uint x = 0; x < setLen; x++) {
            // Every array might have a different length
            uint256 vlen = allowedSets[x].vintages.length;
            uint256 rlen = allowedSets[x].regions.length;
            uint256 slen = allowedSets[x].standards.length;
            uint256 mlen = allowedSets[x].methodologies.length;

            for (uint i = 0; i < vlen; i++) {
                // console.log("DEBUG vintage:", i, allowedSets[x].vintages[i]);

                if (allowedSets[x].vintages[i]==v) {
                    // console.log("DEBUG: match VINTAGES in set:", x);
                    vMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            // Jump to next AttributeSet
            if (vMatch==false) continue;

            for (uint i = 0; i < rlen; i++) {
                // console.log("DEBUG regions:",i, allowedSets[x].regions[i]);

                if (keccak256(abi.encodePacked(allowedSets[x].regions[i]))==keccak256(abi.encodePacked(r))) {
                    // console.log("DEBUG: match in REGIONS in set:", x);
                    rMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            // Jump to next AttributeSet
            if (rMatch==false) continue;


            for (uint i = 0; i < slen; i++) {
                // console.log("DEBUG standards:",i, allowedSets[x].standards[i]);
                
                if (keccak256(abi.encodePacked(allowedSets[x].standards[i]))==keccak256(abi.encodePacked(s))) {
                    // console.log("DEBUG: match in STANDARDS in set:", x);
                    sMatch = true;
                    break;
                }
                else {
                    continue;
                }
            }

            // Jump to next AttributeSet
            if (sMatch==false) continue;

            for (uint i = 0; i < mlen; i++) {
                // console.log("DEBUG methodologies:",i, allowedSets[x].methodologies[i]);
                
                if (keccak256(abi.encodePacked(allowedSets[x].methodologies[i]))==keccak256(abi.encodePacked(m))) {
                    // console.log("DEBUG: match in METHODOLOGIES in set:", x);
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
