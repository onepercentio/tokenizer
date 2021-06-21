pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractRegistry is Ownable {
    address public batchCollectionAddress;
    address public projectCollectionAddress;
    address public projectFactoryAddress;

    function setProjectCollectionAddress(address _address) public onlyOwner {
        projectCollectionAddress = _address;
    }
    
    function setBatchCollectionAddress(address _address) public onlyOwner {
        batchCollectionAddress = _address;
    }

    function setProjectFactoryAddress(address _address) public onlyOwner {
        projectFactoryAddress = _address;
    }
}
