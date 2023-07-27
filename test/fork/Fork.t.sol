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

contract ForkTest is Test {
  IAddressesProvider sismoAddressesProvider;
  IAvailableRootsRegistry availableRootsRegistry;

  AuthRequestBuilder authRequestBuilder;
  ClaimRequestBuilder claimRequestBuilder;
  SignatureBuilder signatureBuilder;
  RequestBuilder requestBuilder;

  function setUp() public virtual {
    vm.createSelectFork({urlOrAlias: "mainnet"});

    sismoAddressesProvider = IAddressesProvider(0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6);
    availableRootsRegistry = IAvailableRootsRegistry(
      sismoAddressesProvider.get(string("sismoConnectAvailableRootsRegistry"))
    );

    authRequestBuilder = AuthRequestBuilder(
      sismoAddressesProvider.get(string("authRequestBuilder-v1.1"))
    );
    claimRequestBuilder = ClaimRequestBuilder(
      sismoAddressesProvider.get(string("claimRequestBuilder-v1.1"))
    );
    signatureBuilder = SignatureBuilder(
      sismoAddressesProvider.get(string("signatureBuilder-v1.1"))
    );
    requestBuilder = RequestBuilder(sismoAddressesProvider.get(string("requestBuilder-v1.1")));
  }

  function _registerTreeRoot(uint256 root) internal {
    address rootsRegistryOwner = availableRootsRegistry.owner();
    // prank to the rootsRegistryOwner
    vm.startPrank(rootsRegistryOwner);
    availableRootsRegistry.registerRoot(root);
    vm.stopPrank();
  }
}
