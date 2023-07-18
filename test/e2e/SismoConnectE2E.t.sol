// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/utils/Fmt.sol";
import {HydraS3BaseTest} from "../verifiers/hydra-s3/HydraS3BaseTest.t.sol";
import {SismoConnect, RequestBuilder, ClaimRequestBuilder} from "src/SismoConnectLib.sol";
import {ZKDropERC721} from "src/misc/ZKDropERC721.sol";
import {CheatSheet} from "src/misc/CheatSheet.sol";
import "src/utils/Structs.sol";
import {SismoConnectHarness} from "../harness/SismoConnectHarness.sol";

import {AuthBuilder} from "src/utils/AuthBuilder.sol";
import {ClaimBuilder} from "src/utils/ClaimBuilder.sol";
import {ResponseBuilder, ResponseWithoutProofs} from "../utils/ResponseBuilderLib.sol";
import {BaseDeploymentConfig} from "script/BaseConfig.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {UpgradeableExample} from "../misc/UpgradeableExample.sol";

// E2E tests for SismoConnect Solidity Library
// These tests are made with proofs generated from the Vault App
// These tests should not use any Verifier mocks

contract SismoConnectE2E is HydraS3BaseTest {
  using ResponseBuilder for SismoConnectResponse;
  using ResponseBuilder for ResponseWithoutProofs;

  SismoConnectHarness sismoConnect;
  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;

  // default values for tests
  bytes16 public DEFAULT_APP_ID = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 public DEFAULT_NAMESPACE = bytes16(keccak256("main"));
  bytes32 public DEFAULT_VERSION = bytes32("sismo-connect-v1.1");
  bytes public DEFAULT_SIGNED_MESSAGE = abi.encode(user);

  bool public DEFAULT_IS_IMPERSONATION_MODE = false;

  ResponseWithoutProofs public DEFAULT_RESPONSE =
    ResponseBuilder
      .emptyResponseWithoutProofs()
      .withAppId(DEFAULT_APP_ID)
      .withVersion(DEFAULT_VERSION)
      .withNamespace(DEFAULT_NAMESPACE)
      .withSignedMessage(DEFAULT_SIGNED_MESSAGE);

  ClaimRequest claimRequest;
  AuthRequest authRequest;
  SignatureRequest signature;

  bytes16 immutable APP_ID_ZK_DROP = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 immutable ZK = 0xe9ed316946d3d98dfcd829a53ec9822e;
  ZKDropERC721 zkdrop;

  CheatSheet cheatsheet;

  function setUp() public virtual override {
    super.setUp();
    sismoConnect = new SismoConnectHarness(DEFAULT_APP_ID, DEFAULT_IS_IMPERSONATION_MODE);
    claimRequest = sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    authRequest = sismoConnect.exposed_buildAuth({authType: AuthType.VAULT});
    signature = sismoConnect.exposed_buildSignature({message: abi.encode(user)});

    zkdrop = new ZKDropERC721({
      appId: APP_ID_ZK_DROP,
      groupId: ZK,
      name: "ZKDrop test",
      symbol: "test",
      baseTokenURI: "https://test.com"
    });
    console.log("ZkDrop contract deployed at", address(zkdrop));

    cheatsheet = new CheatSheet();
  }

  function test_SismoConnectLibWithOnlyClaimAndMessage() public {
    (, bytes memory responseEncoded) = hydraS3Proofs.getResponseWithOneClaimAndSignature();

    sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: requestBuilder.build({
        claim: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
        signature: sismoConnect.exposed_buildSignature({message: abi.encode(user)})
      })
    });
  }

  function test_SismoConnectLibWithTwoClaimsAndMessage() public {
    (, bytes memory responseEncoded) = hydraS3Proofs.getResponseWithTwoClaimsAndSignature();

    ClaimRequest[] memory claims = new ClaimRequest[](2);
    claims[0] = sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = sismoConnect.exposed_buildClaim({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});

    sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: requestBuilder.build({
        claims: claims,
        signature: sismoConnect.exposed_buildSignature({message: abi.encode(user)})
      })
    });
  }

  function test_SismoConnectLibWithOnlyOneAuth() public {
    (, bytes memory responseEncoded) = hydraS3Proofs.getResponseWithOnlyOneAuthAndMessage();

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      signature: signature
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      responseEncoded,
      request
    );
    assertTrue(verifiedResult.auths[0].userId != 0);
  }

  function test_SismoConnectLibWithClaimAndAuth() public {
    (, bytes memory responseEncoded) = hydraS3Proofs.getResponseWithOneClaimOneAuthAndOneMessage();
    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      claim: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
      signature: signature
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      responseEncoded,
      request
    );
    assertTrue(verifiedResult.auths[0].userId != 0);
  }

  function test_ClaimAndAuthWithSignedMessageZKDROP() public {
    // address that reverts if not modulo SNARK_FIELD after hashing the signedMessage for the circuit
    // should keep this address for testing purposes
    user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;

    // proof of membership for user in group 0xe9ed316946d3d98dfcd829a53ec9822e
    // vault ownership
    // signedMessage: 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE
    bytes
      memory responseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76312e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c00e13d5898f45a0578526ca3d9048c9a0ed6a6dc6af46118f330a10c2bd905a180a5606df9b8c074aa82aa92fba759f79bfe2ea93b120f88477fc2506071e07932953767a6bba7cde1264cd886e85f97233cf12dec2cdf5ee8f3d295a1c603ee200a14357ed867808c4c9cfdd3eadbaaccab985c3c98563eb9bd97f0ae4a86dfb1854e21c9405301c914a1bcd93e827f34bcedb21419c5edcf2c022a719da63262a905da8df1c751d7aa8761ca691f950011a9016f152e06d67a076f72547002b1af4e79cb9e150f94bfb43b295ee3eba90f4f21c096cbda50215e37d86b095920d953743b8c045b0d4342370648b1f9444ce5c706602f20d2df4a2139997ee4b000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c02f1f6f738b95cb3ad82c8d6f9d3f76542a489959b5c54da7d9d7b48413136b580dcd5851ffe286e00cbcdb644972e2f98b96772258f243160c501fa350a98282301793ae676f391ef110b70c0fd3286c5f2679582cbb3371792174af6f1c78490851df3f5b6054ab215fd07ad52bcaac91e7a342611126ec56ceed3ce47a756e066fea74f29aba48ed861174b8adb71406661e423e19a9c49df73c8b2b868d3d2c9fe708d9654b09e0ae44948b81d3970118e6bc771ca258f79a5047bfac8e8c2bd36792147ed1c1e4d5bea0ccc70abc636b98e49aa89f3b857673b3cac2cad809c1face7ad71275738dd61ca3683d1edb5d6acea0b177ddcf7771ff8758f057000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa0d4f2a0d3c9c82fbdb9f118c948baa9d8c0b2f467855c6b4cb43a95631d8521004f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a5000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    zkdrop.claimWithSismoConnect(responseEncoded, user);
  }

  function test_TwoClaimsOneVaultAuthWithSignature() public {
    ClaimRequest[] memory claims = new ClaimRequest[](2);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});

    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature
    });

    (, bytes memory responseEncoded) = hydraS3Proofs
      .getResponseWithTwoClaimsOneAuthAndOneSignature();

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_ThreeClaimsOneVaultAuthWithSignatureOneClaimOptional() public {
    ClaimRequest[] memory claims = new ClaimRequest[](3);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});
    claims[2] = claimRequestBuilder.build({
      groupId: 0x42c768bb8ae79e4c5c05d3b51a4ec74a,
      isOptional: true,
      isSelectableByUser: false
    });

    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature
    });

    (, bytes memory responseEncoded) = hydraS3Proofs
      .getResponseWithTwoClaimsOneAuthAndOneSignature();

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_ThreeClaimsOneVaultAuthOneTwitterAuthWithSignatureOneClaimOptional() public {
    ClaimRequest[] memory claims = new ClaimRequest[](3);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});
    claims[2] = claimRequestBuilder.build({
      groupId: 0x42c768bb8ae79e4c5c05d3b51a4ec74a,
      isOptional: true,
      isSelectableByUser: false
    });

    AuthRequest[] memory auths = new AuthRequest[](2);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});
    auths[1] = authRequestBuilder.build({
      authType: AuthType.TWITTER,
      isOptional: true,
      isSelectableByUser: true
    });

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature
    });

    (, bytes memory responseEncoded) = hydraS3Proofs
      .getResponseWithTwoClaimsOneAuthAndOneSignature();

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_OneClaimOneOptionalTwitterAuthOneGithubAuthWithSignature() public {
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

    AuthRequest[] memory auths = new AuthRequest[](2);
    auths[0] = authRequestBuilder.build({authType: AuthType.GITHUB});
    auths[1] = authRequestBuilder.build({
      authType: AuthType.TWITTER,
      isOptional: true,
      isSelectableByUser: true
    });

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature
    });

    bytes
      memory responseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76312e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000009e000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000100100000000000000000000000000009999037000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c01f5237cda37ca2237bfa10de427ae030eeec24a6ce9d8d1131b15f7fcb5f168f2cd27a37a8cecf4a922e209910d04ab67165610d401aeb8d3f9c8b4a6f81239425860952ce7cdf52b06c6f7861e10ab049b8df45c18b1fec6230c1bb9d5744fe1cc5acd00634a05a6dbf82f95b338f2d71fb3c88ec5219b2b8c98bea55a4dd3014d0a71a383a1e1d31902460cf0fa23c528be517436887dd4b82af41d6ab09c2062c4454dca040336cda21c314f5bc213f0b917908a89c5b0c1b2db31b8953ba1e1b07dbd0f19bec715b1aa331f632c258d9e084e309972550004c05f6340d732ca967c1ff768dd26409f9f987b9522fad5c4112f203a9b93119fadc85e30c9a000000000000000000000000100100000000000000000000000000009999037009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000100200000000000000000000000000288480976500000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c0254797b44b8f3a253c02e3b84c8694458a8d498c2592e7b36c965519fc92503400c58413e606342362077d258766e55fc09135bdcb933e11db23bdcdce4ad23c2828525ef73b62575d2f2e6a471349e28e3ca63bc6b542bd6a0c8a3995750deb2da5fc828781d6aa5c5993bc43cb1e58cf6ddb8353503efc0d8f927956c9ec871dc864a6441d35fd9b774ac4a5380933666f6ad7c9e1ef1f1b24b87037fa2f5513ac71eaa4f51ddcf248dafff8e6c8205cabafcfacab21b7adb98167e9c5bb5f2aea54095c0246922547be93dce8b8e3fd87d4c5399d67377e63d9b90a30195025918b506c8d12293e48f224acddf120e8f890fe851bb9ba178b642beb4ded23000000000000000000000000100200000000000000000000000000288480976509f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73332e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c025f517407b6ea0ed90092fefb10a570a25e5c769acb42b98671e5ecc381a01bc26f2a04c85eec86c263e919be89ed6bae72fff9267e25674b0b1242f68c9722601dc85685a7d3423f9b1a3b63ef08a76379118fb1eb29821acd8165ae8e1d12f0528e916f26707be18a37f1c8f0a2792a5891d340438d6221cb137614c8b5b7520c0d1e29393509cbd8822cd8f5278e8a4203ca6baf007f5328b5abe9e175d802d3ecc77bb73e2f85b32033405a3dbe0920ac3a318bd329fc1b410e22f98f518269b9554c33dbc905c5f210d9555ca2b166733c814e904bd21ea298e2894ae6b0251474f760ccc6c335321cc4fb58f6d858ac6d6de7c2670a93148f9d3a1b060000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa0d4f2a0d3c9c82fbdb9f118c948baa9d8c0b2f467855c6b4cb43a95631d8521004f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000086297004382ede0550866e3e15fdce4b5b9fa843f0c12fece0fa11cf69ba5ff01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a5000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_GitHubAuth() public {
    (, bytes memory encodedResponse) = hydraS3Proofs.getResponseWithGitHubAuth();

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB}),
      signature: signature
    });

    sismoConnect.exposed_verify({responseBytes: encodedResponse, request: request});
  }

  function test_GitHubAuthWithoutSignature() public {
    (, bytes memory encodedResponse) = hydraS3Proofs.getResponseWithGitHubAuthWithoutSignature();

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB})
    });

    sismoConnect.exposed_verify({responseBytes: encodedResponse, request: request});
  }

  function test_withProxy() public {
    SignatureRequest memory signatureRequest = sismoConnect.exposed_buildSignature({
      message: abi.encode(user)
    });

    UpgradeableExample sismoConnectImplem = new UpgradeableExample(
      DEFAULT_APP_ID,
      DEFAULT_IS_IMPERSONATION_MODE,
      0xe9ed316946d3d98dfcd829a53ec9822e
    );

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(sismoConnectImplem),
      address(1),
      abi.encodeWithSelector(
        sismoConnectImplem.initialize.selector,
        bytes16(0xe9ed316946d3d98dfcd829a53ec9822e)
      )
    );

    UpgradeableExample upgradeable = UpgradeableExample(address(proxy));

    (, bytes memory responseEncoded) = hydraS3Proofs.getResponseWithOneClaimAndSignature();

    upgradeable.exposed_verify({responseBytes: responseEncoded, signature: signatureRequest});

    // add an additional groupId in the contract
    upgradeable.addGroupId({groupId: 0xff7653240feecd7448150005a95ac86b});

    // verify again
    // it should throw since the response is the same but another claim request is required
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupIdNotFound(bytes16)",
        bytes16(0xff7653240feecd7448150005a95ac86b)
      )
    );
    upgradeable.exposed_verify({responseBytes: responseEncoded, signature: signatureRequest});
  }

  function test_RevertWithInvalidSismoIdentifier() public {
    (SismoConnectResponse memory response, ) = hydraS3Proofs
      .getResponseWithGitHubAuthWithoutSignature();

    // specify in the response that the proof comes from a telegram ownership
    // but the proof is actually a github ownership
    response.proofs[0].auths[0].authType = AuthType.TELEGRAM;

    // request a telegram proof of ownership
    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.TELEGRAM})
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidSismoIdentifier(bytes32,uint8)",
        0x0000000000000000000000001001000000000000000000000000000099990370,
        4
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(response), request: request});
  }

  function test_CheatSheet() public {
    bytes memory responseBytes = hydraS3Proofs.getCheatSheetResponse();
    cheatsheet.verifySismoConnectResponse(responseBytes);
  }

  // helpers

  function emptyResponse() private pure returns (SismoConnectResponse memory) {
    return ResponseBuilder.empty();
  }
}
