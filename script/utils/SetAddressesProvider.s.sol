// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {IAddressesProvider} from "src/interfaces/IAddressesProvider.sol";
import {BaseDeploymentConfig, DeploymentConfig} from "script/BaseConfig.sol";

contract SetAddressesProvider is Script, BaseDeploymentConfig {
  struct DeployedLibrary {
    address addr;
    string name;
  }

  // useful variables to set libraries addresses in AddressesProvider in batch
  address[] public contractAddresses;
  string[] public contractNames;

  function run() external {
    runFor(vm.envString("CHAIN_NAME"));
  }

  function runFor(string memory _chainName) public {
    console.log("Run for CHAIN_NAME:", _chainName);
    console.log("Sender:", msg.sender);

    vm.startBroadcast();
    _setConfig({chainName: _chainName});

    // associate libraries addresses to names
    DeployedLibrary[] memory deployedLibrariesArray = new DeployedLibrary[](4);
    deployedLibrariesArray[0] = DeployedLibrary({
      addr: address(config.authRequestBuilder),
      name: "authRequestBuilder-v1.1"
    });
    deployedLibrariesArray[1] = DeployedLibrary({
      addr: address(config.claimRequestBuilder),
      name: "claimRequestBuilder-v1.1"
    });
    deployedLibrariesArray[2] = DeployedLibrary({
      addr: address(config.signatureBuilder),
      name: "signatureBuilder-v1.1"
    });
    deployedLibrariesArray[3] = DeployedLibrary({
      addr: address(config.requestBuilder),
      name: "requestBuilder-v1.1"
    });

    // update addresses provider with deployed libraries addresses
    _setLibrariesAddresses(deployedLibrariesArray);

    vm.stopBroadcast();
  }

  function _setLibrariesAddresses(DeployedLibrary[] memory deployedLibrariesArray) private {
    console.log("== Updating Addresses Provider ==");
    IAddressesProvider sismoAddressProvider = IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2);

    for (uint256 i = 0; i < deployedLibrariesArray.length; i++) {
      DeployedLibrary memory deployedLibrary = deployedLibrariesArray[i];
      address currentContractAddress = sismoAddressProvider.get(deployedLibrary.name);

      if (currentContractAddress != deployedLibrary.addr) {
        console.log(
          "current contract address for",
          deployedLibrary.name,
          "is different. Updating address to",
          deployedLibrary.addr
        );
        // save address to update in batch after
        contractAddresses.push(deployedLibrary.addr);
        contractNames.push(deployedLibrary.name);
      } else {
        console.log(
          "current contract address for",
          deployedLibrary.name,
          "is already the expected one. skipping update"
        );
      }
    }

    if (contractAddresses.length > 0) {
      console.log("Updating Addresses Provider in batch...");
      sismoAddressProvider.setBatch(contractAddresses, contractNames);
    }
  }
}
