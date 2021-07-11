// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IContractRegistry {

    function batchCollectionAddress() external view returns (address);

    function projectCollectionAddress() external view returns (address);

    function projectFactoryAddress() external view returns (address);

    function projectERC20FactoryAddress() external view returns (address);

    function checkERC20(address _address) external view returns (bool);

    function addERC20(address _address) external;
}
