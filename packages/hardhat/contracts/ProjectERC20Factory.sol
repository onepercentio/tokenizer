// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ProjectERC20.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";

contract ProjectERC20Factory {

    event TokenCreated(address tokenAddress);

    address[] private deployedContracts; 
    address public contractRegistry;
    mapping (string => address) public pContractRegistry;

    constructor (address _contractRegistry) {
        contractRegistry = _contractRegistry;
    }

    function deployNewToken(
        string memory _name, 
        string memory _symbol,
        string memory _projectIdentifier,
        string memory _vintage,
        address _contractRegistry) 
    public {
        // console.log("DEBUG: deploying new pERC20");

        string memory _pTokenIdentifier = append(_name, _symbol, _projectIdentifier, _vintage);
        // console.log(_pTokenIdentifier);
        // Necessary to avoid two of the same project-tokens being deployed with differing symbol/name
        require(!checkExistence(_pTokenIdentifier), "Matching pERC20 already exists");

        ProjectERC20 t = new ProjectERC20(_name, _symbol, _projectIdentifier, _vintage, _contractRegistry);
        deployedContracts.push(address(t));
        // console.log("DEBUG: Deployed new pERC20 at ", address(t));
        pContractRegistry[_pTokenIdentifier] = address(t);

        emit TokenCreated(address(t));
    }

     // Deploy providing an NFT as template, currently would work only with one single collection
     function deployFromTemplate(uint256 tokenId) public {
        address collection = IContractRegistry(contractRegistry).batchCollectionAddress();
        // (string memory pid, , ) = IBatchCollection(collection).getNftData(tokenId);
        (string memory pid, string memory vintage, , , ) = IBatchCollection(collection).getNftData(tokenId);

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
        // console.log(deployedContracts);
        return deployedContracts;
    }
}
