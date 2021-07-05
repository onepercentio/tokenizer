// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ProjectERC20.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";

contract ProjectERC20Factory {

    event TokenCreated(address tokenAddress);

    address public contractRegistry;

    address[] private deployedContracts; // Probably obsolete, moved to registry
    mapping (string => address) public pContractRegistry; // Probably obsolete, moved to registry

    constructor (address _contractRegistry) {
        contractRegistry = _contractRegistry;
    }


    function deployNewToken(
        string memory _name, 
        string memory _symbol,
        string memory _projectIdentifier,
        uint16 _vintage,
        address _contractRegistry) 
    public {
        // string memory _pTokenIdentifier = append(_name, _symbol, _projectIdentifier);
        // // Necessary to avoid two of the same project-tokens being deployed with differing symbol/name
        // require(!checkExistence(_pTokenIdentifier), "Matching pERC20 already exists");

        ProjectERC20 t = new ProjectERC20(_name, _symbol, _projectIdentifier, _vintage, _contractRegistry);

        // Register deployed ERC20 in ContractRegistry
        IContractRegistry(contractRegistry).addERC20(address(t));
        
        // Move registration to ContractRegistry
        deployedContracts.push(address(t));
        pContractRegistry[_projectIdentifier] = address(t);

        emit TokenCreated(address(t));
    }


     // Deploy providing an NFT as template, currently would work only with one single collection
     function deployFromTemplate(uint256 tokenId) public {
        address collection = IContractRegistry(contractRegistry).batchCollectionAddress();
        (string memory pid, uint16 vintage, , , ) = IBatchCollection(collection).getNftData(tokenId);

        require(!checkExistence(pid), "Matching pERC20 already exists");
        /// @TODO: Needs some consideration about automatic naming
        console.log("DEBUG: deploying from template");
        deployNewToken("pERC20-P-XYZ-Vin2015", "PV20-ID123-y15", pid, vintage, contractRegistry);

     }


    // Helper function to create unique pERC20 identifying string
    function append(string memory a, string memory b, string memory c, string memory d) 
        internal pure returns (string memory)  {
        return string(abi.encodePacked(a, b, c, d));
    }


    // Checks if same pToken has already been deployed
    function checkExistence(string memory _pTokenIdentifier) internal view returns (bool) {
        if (pContractRegistry[_pTokenIdentifier] == address(0)) {
            console.log("DEBUG: checkExistence: false");
            return false;
        }
        else {
            console.log("DEBUG: checkExistence: true");
            return true;
        }
    }

    // Lists addresses of deployed contracts
    function getContracts() public view returns (address[] memory) {
        for (uint256 i = 0; i < deployedContracts.length; i++) {
            console.log("sol: logging contract",i, deployedContracts[i]);
        } 
        return deployedContracts;
    }
}
