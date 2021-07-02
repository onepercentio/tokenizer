// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IContractRegistry.sol";

import "hardhat/console.sol";


// the ContractRegistry can be utilized by other contracts to query the whitelisted contracts
contract ContractRegistry is Ownable, IContractRegistry {
    address private _batchCollectionAddress;
    address private _projectCollectionAddress;
    address private _projectFactoryAddress;
    address private _ProjectERC20FactoryAddress;

    mapping (address => bool) public pERC20Registry;

    // should be moved here from ProjectERC20Factory.sol
    mapping (string => address) public pidToERC20;

    // Currently not used, replaced by OnlyBy modifier
    modifier onlyFactory() {
        require(_ProjectERC20FactoryAddress != address(0), "ProjectERC20FactoryAddress not set");
        require(_ProjectERC20FactoryAddress == _msgSender(), "Caller is not the factory");
        _;
    }

    modifier OnlyBy(address _factory, address _owner) {
        require(_factory == _msgSender() || _owner == _msgSender(), "Caller is not the factory");

     _;
    }


    // --- Setters ---

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

    // Security: function should only be called by owner or tokenFactory
    function addERC20(address _address) external override OnlyBy(_ProjectERC20FactoryAddress, owner()) {
        console.log("DEBUG sol: addERC20", _address);
        pERC20Registry[_address] = true;
    }


    // --- Getters ---

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

    function checkERC20(address _address) external view override returns (bool) {
        console.log("DEBUG sol: checkERC20", _address);
        return pERC20Registry[_address];
    }   
}
