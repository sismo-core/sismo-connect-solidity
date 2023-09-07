// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {DeployLibraries, DeploymentConfig} from "script/DeployLibraries.s.sol";
import {SetAddressesProvider} from "script/utils/SetAddressesProvider.s.sol";
import {AddressesProviderMock} from "test/mocks/AddressesProviderMock.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {IAddressesProvider} from "src/interfaces/IAddressesProvider.sol";

contract DeployLibrariesTest is BaseTest {
  DeployLibraries deploy;
  DeploymentConfig contracts;
  SetAddressesProvider setAddressesProvider;

  function setUp() public virtual override {
    super.setUp();

    // clean the deployments/test folder
    string[] memory removeFolderInputs = new string[](3);
    removeFolderInputs[0] = "rm";
    removeFolderInputs[1] = "-rf";
    removeFolderInputs[2] = string.concat(vm.projectRoot(), "/deployments/test");
    vm.ffi(removeFolderInputs);

    deploy = new DeployLibraries();
    // deploy all libraries by calling the `runFor` function of the DeployLibraries script contract
    (bool success, bytes memory result) = address(deploy).delegatecall(
      abi.encodeWithSelector(DeployLibraries.runFor.selector, "test")
    );
    require(success, "DeployLibraries script did not run successfully!");
    contracts = abi.decode(result, (DeploymentConfig));

    // save the test config in the `deployments` folder
    // so that the libraries addresses are available for the other scripts
    string[] memory inputs = new string[](2);
    inputs[0] = "yarn";
    inputs[1] = "save-deployments";
    vm.ffi(inputs);

    // set the addresses in the AddressesProvider contract
    setAddressesProvider = new SetAddressesProvider();
    (bool success2, ) = address(setAddressesProvider).delegatecall(
      abi.encodeWithSelector(SetAddressesProvider.runFor.selector, "test")
    );
    require(success2, "SetAddressesProvider script did not run successfully!");
  }

  function testDeployLibraries() public {
    // check that the libraries were deployed
    // and that the addresses in the AddressesProvider were updated accordingly
    assertEq(
      address(contracts.authRequestBuilder),
      IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).get(string("authRequestBuilder-v1.1"))
    );
    assertFalse(address(contracts.authRequestBuilder) == address(authRequestBuilder));

    assertEq(
      address(contracts.claimRequestBuilder),
      IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).get(string("claimRequestBuilder-v1.1"))
    );
    assertFalse(address(contracts.claimRequestBuilder) == address(claimRequestBuilder));

    assertEq(
      address(contracts.signatureBuilder),
      IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).get(string("signatureBuilder-v1.1"))
    );
    assertFalse(address(contracts.signatureBuilder) == address(signatureBuilder));

    assertEq(
      address(contracts.requestBuilder),
      IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).get(string("requestBuilder-v1.1"))
    );
    assertFalse(address(contracts.requestBuilder) == address(requestBuilder));
  }
}
