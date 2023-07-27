// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {IAddressesProvider, AuthRequestBuilder, ClaimRequestBuilder, SignatureBuilder, RequestBuilder} from "src/SismoConnectLib.sol";

interface IAvailableRootsRegistry {
  event RegisteredRoot(uint256 root);

  function registerRoot(uint256 root) external;

  function owner() external view returns (address);
}

contract BaseTest is Test {
  IAddressesProvider sismoAddressesProvider =
    IAddressesProvider(0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6);
  IAvailableRootsRegistry availableRootsRegistry =
    IAvailableRootsRegistry(
      sismoAddressesProvider.get(string("sismoConnectAvailableRootsRegistry"))
    );

  AuthRequestBuilder authRequestBuilder =
    AuthRequestBuilder(sismoAddressesProvider.get(string("authRequestBuilder-v1.1")));
  ClaimRequestBuilder claimRequestBuilder =
    ClaimRequestBuilder(sismoAddressesProvider.get(string("claimRequestBuilder-v1.1")));
  SignatureBuilder signatureBuilder =
    SignatureBuilder(sismoAddressesProvider.get(string("signatureBuilder-v1.1")));
  RequestBuilder requestBuilder =
    RequestBuilder(sismoAddressesProvider.get(string("requestBuilder-v1.1")));

  function _registerTreeRoot(uint256 root) internal {
    address rootsRegistryOwner = availableRootsRegistry.owner();
    // prank to the rootsRegistryOwner
    vm.startPrank(rootsRegistryOwner);
    availableRootsRegistry.registerRoot(root);
    vm.stopPrank();
  }
}
