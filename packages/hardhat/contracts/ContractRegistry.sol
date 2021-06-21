// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IContractRegistry.sol";


// the ContractRegistry can be utilized by other contracts to query the whitelisted contracts
contract ContractRegistry is Ownable, IContractRegistry {
    address private _batchCollectionAddress;
    address private _projectCollectionAddress;
    address private _projectFactoryAddress;
    address private _ProjectERC20FactoryAddress;

    // Setters
    function setProjectCollectionAddress(address _address) public onlyOwner {
        _projectCollectionAddress = _address;
    }
    
    function setBatchCollectionAddress(address _address) public onlyOwner {
        _batchCollectionAddress = _address;
    }

    function setProjectFactoryAddress(address _address) public onlyOwner {
        _projectFactoryAddress = _address;
    }

    function setProjectERC20FactoryAddress(address _address) public onlyOwner {
        _ProjectERC20FactoryAddress = _address;
    }

    // Getters
    function batchCollectionAddress() external view override returns (address) {
        return _batchCollectionAddress;
    }

    function projectCollectionAddress() external view override returns (address) {
        return _projectCollectionAddress;

    }
    function projectFactoryAddress() external view override returns (address) {
        return _projectFactoryAddress;
    }

    function projectERC20FactoryAddress() external view override returns (address) {
        return _ProjectERC20FactoryAddress;
    }
}
