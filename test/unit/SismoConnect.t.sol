// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseTest} from "test/BaseTest.t.sol";
import {SismoConnectHarness} from "test/harness/SismoConnectHarness.sol";
import "src/utils/Structs.sol";

contract SismoConnectTest is BaseTest {
  SismoConnectHarness sismoConnect;

  bytes16 public constant DEFAULT_APP_ID = bytes16("default-app-id");
  bool public constant IS_IMPERSONATION_MODE = false;

  function setUp() public virtual override {
    BaseTest.setUp();

    sismoConnect = new SismoConnectHarness({
      appId: DEFAULT_APP_ID,
      isImpersonationMode: IS_IMPERSONATION_MODE
    });
  }

  function test_RevertWith_EmptyMessageIfSismoConnectResponseIsEmpty() public {
    bytes memory responseBytes = hex"";
    ClaimRequest memory claimRequest = claimRequestBuilder.build({groupId: bytes16("group-id")});
    // we just expect a revert with an empty responseBytes as far as the decoding will not be successful
    vm.expectRevert();
    sismoConnect.exposed_verify({responseBytes: responseBytes, claim: claimRequest});
  }

  function test_RevertWith_InvalidUserIdAndIsSelectableByUserAuthType() public {
    // When `userId` is 0, it means the app does not require a specific auth account and the user needs
    // to choose the account they want to use for the app.
    // When `isSelectableByUser` is true, the user can select the account they want to use.
    // The combination of `userId = 0` and `isSelectableByUser = false` does not make sense and should not be used.

    // Here we do expect the revert since we set isSelectableByUser to false
    // and we keep the default value for userId which is 0
    // effectivelly triggering the revert
    // Note: we use an AuthType different from VAULT to not trigger another revert
    vm.expectRevert(abi.encodeWithSignature("InvalidUserIdAndIsSelectableByUserAuthType()"));
    sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      isOptional: false,
      isSelectableByUser: false
    });
  }

  function test_RevertWith_InvalidUserIdAndAuthType() public {
    // When `userId` is 0, it means the app does not require a specific auth account and the user needs
    // to choose the account they want to use for the app.
    // When `isSelectableByUser` is true, the user can select the account they want to use.
    // The combination of `userId = 0` and `isSelectableByUser = false` does not make sense and should not be used.

    // Here we set isSelectableByUser to false but we add a userId different from zero
    // while choosing The AuthType VAULT, which does NOT make sense since it states that we allow the user to choose a vault account in his vault
    // but in the case of the AuthType VAULT, the account is the vault itself and therefore there is no choice to make
    // we should definitely revert based on this reasoning
    vm.expectRevert(abi.encodeWithSignature("InvalidUserIdAndAuthType()"));
    sismoConnect.exposed_buildAuth({
      authType: AuthType.VAULT,
      isOptional: false,
      isSelectableByUser: false,
      userId: uint256(bytes32("wrong-id"))
    });
  }
}
