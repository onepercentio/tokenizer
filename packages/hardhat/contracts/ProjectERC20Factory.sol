// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "hardhat/console.sol"; // dev & testing
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ProjectERC20.sol";

import "./IContractRegistry.sol";
import "./IBatchCollection.sol";
import "./ProjectCollection.sol";

library uintConversion {
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

// Project-Vintage ERC20 Factory contract for BatchNFT fractionalization
// Locks in received ERC721 BatchNFTs and can mint corresponding quantity of ERC20s
// Permissionless, anyone can deploy new ERC20s unless they do not yet exist and pid exists
contract ProjectERC20Factory {
    event TokenCreated(address tokenAddress);

    address public contractRegistry;
    address[] private deployedContracts;     // Probably obsolete, moved to registry
    mapping (string => address) public pContractRegistry; 

    constructor (address _contractRegistry) {
        contractRegistry = _contractRegistry;
    }


    // Function to deploy new pERC20s
    // Note: Function could be internal, but that would disallow pre-deploying ERC20s without existing NFTs 
    function deployNewToken(
        string memory pvId,
        string memory projectId,
        uint16 vintage,
        address _contractRegistry) 
    public {
        require(!checkExistence(pvId), "Matching pERC20 already exists");

        address c = IContractRegistry(contractRegistry).projectCollectionAddress();
        require(ProjectCollection(c).projectIds(projectId)==true, "Project does not yet exist");

        string memory standard;
        string memory methodology;
        string memory region;

        (standard, methodology, region) = ProjectCollection(c).getProjectDataByProjectId(projectId);
        // Todo: Needs some consideration about automatic naming
        ProjectERC20 t = new ProjectERC20(pvId, pvId, projectId, vintage, standard, methodology, region, _contractRegistry);

        // Register deployed ERC20 in ContractRegistry
        IContractRegistry(contractRegistry).addERC20(address(t));
        
        // Move registration to ContractRegistry
        deployedContracts.push(address(t));
        pContractRegistry[pvId] = address(t);

        emit TokenCreated(address(t));
    }


     // Deploy providing a BatchNFT as template, currently would work only with one single collection
     function deployFromTemplate(uint256 tokenId) public {
        // console.log("DEBUG: deploying from template");
        address collection = IContractRegistry(contractRegistry).batchCollectionAddress();
        (string memory pid, uint16 vintage, , , ) = IBatchCollection(collection).getNftData(tokenId);

        string memory pvId = projectVintageId(pid, uintConversion.uint2str(vintage));
        require(!checkExistence(pvId), "Matching pERC20 already exists");

        deployNewToken(pvId, pid, vintage, contractRegistry);

     }


    // Helper function to create unique project-vintage identifying string
    function projectVintageId(string memory pid, string memory vintage) 
        internal pure returns (string memory)  {
        return string(abi.encodePacked(pid, vintage));
    }


    // Checks if same pToken has already been deployed
    function checkExistence(string memory _pTokenIdentifier) internal view returns (bool) {
        if (pContractRegistry[_pTokenIdentifier] == address(0)) {
            // console.log("DEBUG: checkExistence: false");
            return false;
        }
        else {
            // console.log("DEBUG: checkExistence: true");
            return true;
        }
    }

    // Lists addresses of deployed contracts
    function getContracts() public view returns (address[] memory) {
        for (uint256 i = 0; i < deployedContracts.length; i++) {
            // console.log("DEBUG sol: logging contract",i, deployedContracts[i]);
        } 
        return deployedContracts;
    }
}


