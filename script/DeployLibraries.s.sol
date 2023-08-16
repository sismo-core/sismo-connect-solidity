// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {BaseDeploymentConfig, DeploymentConfig} from "script/BaseConfig.sol";
import {IAddressesProvider} from "src/interfaces/IAddressesProvider.sol";
import {AuthRequestBuilder} from "src/utils/AuthRequestBuilder.sol";
import {ClaimRequestBuilder} from "src/utils/ClaimRequestBuilder.sol";
import {SignatureBuilder} from "src/utils/SignatureBuilder.sol";
import {RequestBuilder} from "src/utils/RequestBuilder.sol";

/**
 * @title DeployLibraries Script
 * @notice To test this script locally, run:
 * in a first terminal: `anvil fork-url https://rpc.ankr.com/polygon_mumbai`
 * in a second terminal: `cast rpc anvil_impersonateAccount`
 * and finally: `CHAIN_NAME=test forge script DeployLibraries --rpc-url localhost --sender 0xbb8fca8f2381cfeede5d7541d7bf76343ef6c67b --unlocked -vvvv`
 * You should see that the libraries are being deployed and successfully set in the AddressesProvider contract.
 * You can then run the `yarn save-deployments` command to save the deployment addresses in the `deployments` folder. You will see the libraries addresses in the `deployments/test/logs-*.json` file.
 */

contract DeployLibraries is Script, BaseDeploymentConfig {
  struct DeployedLibraries {
    AuthRequestBuilder authRequestBuilder;
    ClaimRequestBuilder claimRequestBuilder;
    SignatureBuilder signatureBuilder;
    RequestBuilder requestBuilder;
  }

  struct DeployedLibrary {
    address addr;
    string name;
  }

  // useful variables to set libraries addresses in AddressesProvider in batch
  address[] public contractAddresses;
  string[] public contractNames;

  function run() public {
    runFor(vm.envString("CHAIN_NAME"));
  }

  function runFor(string memory chainName) public returns (DeploymentConfig memory) {
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    vm.startBroadcast();

    _setConfig({chainName: chainName});

    // deploy external libraries
    DeployedLibraries memory deployedLibraries;
    deployedLibraries.authRequestBuilder = _deployAuthRequestBuilder();
    deployedLibraries.claimRequestBuilder = _deployClaimRequestBuilder();
    deployedLibraries.signatureBuilder = _deploySignatureBuilder();
    deployedLibraries.requestBuilder = _deployRequestBuilder();

    // associate libraries addresses to names
    DeployedLibrary[] memory deployedLibrariesArray = new DeployedLibrary[](4);
    deployedLibrariesArray[0] = DeployedLibrary({
      addr: address(deployedLibraries.authRequestBuilder),
      name: "authRequestBuilder-v1.1"
    });
    deployedLibrariesArray[1] = DeployedLibrary({
      addr: address(deployedLibraries.claimRequestBuilder),
      name: "claimRequestBuilder-v1.1"
    });
    deployedLibrariesArray[2] = DeployedLibrary({
      addr: address(deployedLibraries.signatureBuilder),
      name: "signatureBuilder-v1.1"
    });
    deployedLibrariesArray[3] = DeployedLibrary({
      addr: address(deployedLibraries.requestBuilder),
      name: "requestBuilder-v1.1"
    });

    // update addresses provider with deployed libraries addresses
    _setLibrariesAddresses(deployedLibrariesArray);

    // update deployment config with deployed libraries addresses
    // and save it in `deployments` folder
    // only for a successful broadcast
    config = DeploymentConfig({
      authRequestBuilder: address(deployedLibraries.authRequestBuilder),
      claimRequestBuilder: address(deployedLibraries.claimRequestBuilder),
      signatureBuilder: address(deployedLibraries.signatureBuilder),
      requestBuilder: address(deployedLibraries.requestBuilder)
    });
    vm.stopBroadcast();
    _saveDeploymentConfig(chainName);

    return config;
  }

  function _deployAuthRequestBuilder() private returns (AuthRequestBuilder) {
    address authRequestBuilderAddress = config.authRequestBuilder;
    if (authRequestBuilderAddress != address(0)) {
      console.log("Using existing authrequestBuilder:", authRequestBuilderAddress);
      return AuthRequestBuilder(authRequestBuilderAddress);
    }
    AuthRequestBuilder authRequestBuilder = new AuthRequestBuilder();
    console.log("authRequestBuilder Deployed:", address(authRequestBuilder));
    return authRequestBuilder;
  }

  function _deployClaimRequestBuilder() private returns (ClaimRequestBuilder) {
    address claimRequestBuilderAddress = config.claimRequestBuilder;
    if (claimRequestBuilderAddress != address(0)) {
      console.log("Using existing claimRequestBuilder:", claimRequestBuilderAddress);
      return ClaimRequestBuilder(claimRequestBuilderAddress);
    }
    ClaimRequestBuilder claimRequestBuilder = new ClaimRequestBuilder();
    console.log("claimRequestBuilder Deployed:", address(claimRequestBuilder));
    return claimRequestBuilder;
  }

  function _deploySignatureBuilder() private returns (SignatureBuilder) {
    address signatureBuilderAddress = config.signatureBuilder;
    if (signatureBuilderAddress != address(0)) {
      console.log("Using existing signatureBuilder:", signatureBuilderAddress);
      return SignatureBuilder(signatureBuilderAddress);
    }
    SignatureBuilder signatureBuilder = new SignatureBuilder();
    console.log("signatureBuilder Deployed:", address(signatureBuilder));
    return signatureBuilder;
  }

  function _deployRequestBuilder() private returns (RequestBuilder) {
    address requestBuilderAddress = config.requestBuilder;
    if (requestBuilderAddress != address(0)) {
      console.log("Using existing requestBuilder:", requestBuilderAddress);
      return RequestBuilder(requestBuilderAddress);
    }
    RequestBuilder requestBuilder = new RequestBuilder();
    console.log("requestBuilder Deployed:", address(requestBuilder));
    return requestBuilder;
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
