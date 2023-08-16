// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AddressesProviderMock {
  mapping(bytes32 => address) private _contractAddresses;
  string[] private _contractNames;

  /**
   * @dev Sets the address of a contract.
   * @param contractAddress Address of the contract.
   * @param contractName Name of the contract.
   */
  function set(address contractAddress, string memory contractName) public {
    bytes32 contractNameHash = keccak256(abi.encodePacked(contractName));

    if (_contractAddresses[contractNameHash] == address(0)) {
      _contractNames.push(contractName);
    }

    _contractAddresses[contractNameHash] = contractAddress;
  }

  /**
   * @dev Sets the address of multiple contracts.
   * @param contractAddresses Addresses of the contracts.
   * @param contractNames Names of the contracts.
   */
  function setBatch(address[] calldata contractAddresses, string[] calldata contractNames) public {
    require(
      contractAddresses.length == contractNames.length,
      "AddressesProviderMock: Arrays must be the same length"
    );

    for (uint256 i = 0; i < contractAddresses.length; i++) {
      set(contractAddresses[i], contractNames[i]);
    }
  }

  function get(string memory contractName) public view returns (address) {
    bytes32 contractNameHash = keccak256(abi.encodePacked(contractName));

    return _contractAddresses[contractNameHash];
  }
}
