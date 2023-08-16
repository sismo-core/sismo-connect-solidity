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

  function test_verifyProof() public view {
    bytes
      memory responseBytes = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76312e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000100100000000000000000000000000009999037000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c014aa96fb34414b749bb4610bace69a3d3e9ed4b1af6137f7d1a3270590c696bb0074dc54bfd774a3185b445f2b1013bcefb8d8d1b98b186611829ae9ac59a44407b6fa1abaafa92b207d2bed2139ff1a6cd05f56ac2167f89a6b3a3180eceebb107f09ef3f109f1ac13560ed255b5605e340964f5fd6b96ae9e62634cd219d51233f679d2011810af86b8da940f2e3b8ba38716d0ab63a8aa6944c13dd6ec40d0c36d09c76572cc1dfffd527ca60c1828642782322a49ef6df921f0a57ecc65f2706ff429747a7b1dd72643a24dc9be189b0461f155fe5479bde1f78609fece82331e429f79401e878e826c36ada7d85053e00226dd49e6e76fb76ff7b2e43490000000000000000000000001001000000000000000000000000000099990370000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000";
    ClaimRequest memory claimRequest = claimRequestBuilder.build({groupId: bytes16("group-id")});
    // by default, the sismoConnectVerifier contract is mocked
    // the mock will return true for any proof well encoded in the response
    sismoConnect.exposed_verify({responseBytes: responseBytes, claim: claimRequest});
  }
}
