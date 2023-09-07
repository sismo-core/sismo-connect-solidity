// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct DeploymentConfig {
  address authRequestBuilder;
  address claimRequestBuilder;
  address requestBuilder;
  address signatureBuilder;
}

contract BaseDeploymentConfig is Script {
  DeploymentConfig public config;

  string public _chainName;
  bool public _checkIfEmpty;

  address immutable SISMO_ADDRESSES_PROVIDER_V2 = 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;
  address immutable ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

  error ChainNameNotFound(string chainName);

  function _setConfig(string memory chainName) internal {
    if (
      _compareStrings(chainName, "mainnet") ||
      _compareStrings(chainName, "gnosis") ||
      _compareStrings(chainName, "polygon") ||
      _compareStrings(chainName, "optimism") ||
      _compareStrings(chainName, "arbitrum-one") ||
      _compareStrings(chainName, "base") ||
      _compareStrings(chainName, "testnet-goerli") ||
      _compareStrings(chainName, "testnet-sepolia") ||
      _compareStrings(chainName, "testnet-mumbai") ||
      _compareStrings(chainName, "optimism-goerli") ||
      _compareStrings(chainName, "arbitrum-goerli") ||
      _compareStrings(chainName, "base-goerli") ||
      _compareStrings(chainName, "scroll-testnet-goerli") ||
      _compareStrings(chainName, "staging-goerli") ||
      _compareStrings(chainName, "staging-mumbai") ||
      _compareStrings(chainName, "test")
    ) {
      config = _readDeploymentConfig(
        string.concat(vm.projectRoot(), "/deployments/", chainName, ".json")
      );
    } else {
      revert ChainNameNotFound(chainName);
    }
  }

  function _readDeploymentConfig(
    string memory filePath
  ) internal view returns (DeploymentConfig memory) {
    string memory file = _tryReadingFile(filePath);
    return
      DeploymentConfig({
        authRequestBuilder: _tryReadingAddressFromFileAtKey(file, ".authRequestBuilder"),
        claimRequestBuilder: _tryReadingAddressFromFileAtKey(file, ".claimRequestBuilder"),
        requestBuilder: _tryReadingAddressFromFileAtKey(file, ".requestBuilder"),
        signatureBuilder: _tryReadingAddressFromFileAtKey(file, ".signatureBuilder")
      });
  }

  function _tryReadingFile(string memory filePath) internal view returns (string memory) {
    try vm.readFile(filePath) returns (string memory file) {
      return file;
    } catch {
      return "";
    }
  }

  function _tryReadingAddressFromFileAtKey(
    string memory file,
    string memory key
  ) internal view returns (address) {
    try vm.parseJson(file, key) returns (bytes memory encodedAddress) {
      return
        keccak256(encodedAddress) == keccak256(abi.encodePacked(("")))
          ? address(0)
          : abi.decode(encodedAddress, (address));
    } catch {
      return ZERO_ADDRESS;
    }
  }

  function _saveDeploymentConfig(string memory chainName) internal {
    _createFolderIfItDoesNotExists(string.concat(vm.projectRoot(), "/deployments"));
    _createFolderIfItDoesNotExists(string.concat(vm.projectRoot(), "/deployments/tmp"));
    _createFolderIfItDoesNotExists(string.concat(vm.projectRoot(), "/deployments/tmp/", chainName));

    vm.serializeAddress(chainName, "authRequestBuilder", address(config.authRequestBuilder));
    vm.serializeAddress(chainName, "claimRequestBuilder", address(config.claimRequestBuilder));
    vm.serializeAddress(chainName, "requestBuilder", address(config.requestBuilder));
    string memory finalJson = vm.serializeAddress(
      chainName,
      "signatureBuilder",
      address(config.signatureBuilder)
    );

    vm.writeJson(
      finalJson,
      string.concat(vm.projectRoot(), "/deployments/tmp/", chainName, "/run-latest.json")
    );
  }

  function _createFolderIfItDoesNotExists(string memory folderPath) internal {
    string[] memory inputs = new string[](3);
    inputs[0] = "mkdir";
    inputs[1] = "-p";
    inputs[2] = folderPath;
    vm.ffi(inputs);
  }

  function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }
}
