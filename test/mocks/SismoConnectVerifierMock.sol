// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import "../../src/interfaces/ISismoConnectVerifier.sol";
// import "../../src/utils/Structs.sol";

// // this contract is supposed to implement the interface from SismoConnectVerifier contract
// // we dont specify the interface here because for some reason we encounter a stack too deep error up to a local variable
// // when implementing the `verify` function
// // TO replicate the error, try adding the `config` and `request` argument to the verify function
// // it compiles with one of them (+ response) but not with the three arguments
// contract SismoConnectVerifierMock is ISismoConnectVerifier {
//   // struct to store informations about the number of verified auths and claims returned
//   // indexes of the first available slot in the arrays of auths and claims are also stored
//   // this struct is used to avoid stack to deep errors without using via_ir in foundry
//   struct VerifiedArraysInfos {
//     uint256 nbOfAuths; // number of verified auths
//     uint256 nbOfClaims; // number of verified claims
//     uint256 authsIndex; // index of the first available slot in the array of verified auths
//     uint256 claimsIndex; // index of the first available slot in the array of verified claims
//     VerifiedAuth[] auths;
//     VerifiedClaim[] claims;
//   }

//   bytes32 public immutable SISMO_CONNECT_VERSION = "sismo-connect-v1.1";

//   function _check(SismoConnectRequest memory request) internal pure {
//     if (request.auths.length == 0 && request.claims.length == 0) {
//       revert("SismoConnectVerifierMock: no auths or claims");
//     }
//   }

//   function verify(
//     SismoConnectResponse memory response,
//     SismoConnectRequest memory, // request,
//     SismoConnectConfig memory // config
//   ) external pure returns (SismoConnectVerifiedResult memory) {
//     VerifiedArraysInfos memory infos = VerifiedArraysInfos({
//       nbOfAuths: 0,
//       nbOfClaims: 0,
//       authsIndex: 0,
//       claimsIndex: 0,
//       auths: new VerifiedAuth[](0),
//       claims: new VerifiedClaim[](0)
//     });

//     infos = _getVerifiedArrayInfos(infos, response);

//     infos = _saveVerifiedAuthAndClaim(infos, response);

//     return
//       SismoConnectVerifiedResult({
//         appId: response.appId,
//         namespace: response.namespace,
//         version: response.version,
//         auths: infos.auths,
//         claims: infos.claims,
//         signedMessage: response.signedMessage
//       });
//   }

//   function _getVerifiedArrayInfos(
//     VerifiedArraysInfos memory infos,
//     SismoConnectResponse memory response
//   ) private pure returns (VerifiedArraysInfos memory) {
//     // Count the number of auths and claims in the response
//     for (uint256 i = 0; i < response.proofs.length; i++) {
//       infos.nbOfAuths += response.proofs[i].auths.length;
//       infos.nbOfClaims += response.proofs[i].claims.length;
//     }

//     return
//       VerifiedArraysInfos({
//         nbOfAuths: infos.nbOfAuths,
//         nbOfClaims: infos.nbOfClaims,
//         authsIndex: infos.authsIndex,
//         claimsIndex: infos.claimsIndex,
//         auths: new VerifiedAuth[](infos.nbOfAuths),
//         claims: new VerifiedClaim[](infos.nbOfClaims)
//       });
//   }

//   function _saveVerifiedAuthAndClaim(
//     VerifiedArraysInfos memory infos,
//     SismoConnectResponse memory response
//   ) internal pure returns (VerifiedArraysInfos memory) {
//     for (uint256 i = 0; i < response.proofs.length; i++) {
//       (
//         VerifiedAuth memory verifiedAuth,
//         VerifiedClaim memory verifiedClaim
//       ) = _getVerifiedAuthAndClaim(response);
//       if (verifiedAuth.proofData.length != 0) {
//         infos.auths[infos.authsIndex] = verifiedAuth;
//         infos.authsIndex++;
//       }
//       if (verifiedClaim.proofData.length != 0) {
//         infos.claims[infos.claimsIndex] = verifiedClaim;
//         infos.claimsIndex++;
//       }
//     }

//     return infos;
//   }

//   function _getVerifiedAuthAndClaim(
//     SismoConnectResponse memory response
//   ) private pure returns (VerifiedAuth memory, VerifiedClaim memory) {
//     VerifiedAuth memory verifiedAuth;
//     VerifiedClaim memory verifiedClaim;

//     if (response.proofs[0].auths.length != 0) {
//       verifiedAuth = VerifiedAuth({
//         authType: response.proofs[0].auths[0].authType,
//         isAnon: response.proofs[0].auths[0].isAnon,
//         userId: response.proofs[0].auths[0].userId,
//         proofData: response.proofs[0].proofData,
//         extraData: response.proofs[0].auths[0].extraData
//       });
//       // verifiedAuth = VerifiedAuth({
//       //   authType: AuthType.VAULT,
//       //   isAnon: false,
//       //   userId: 0,
//       //   proofData: "123",
//       //   extraData: ""
//       // });
//     }
//     if (response.proofs[0].claims.length != 0) {
//       verifiedClaim = VerifiedClaim({
//         claimType: response.proofs[0].claims[0].claimType,
//         groupId: response.proofs[0].claims[0].groupId,
//         groupTimestamp: response.proofs[0].claims[0].groupTimestamp,
//         value: response.proofs[0].claims[0].value,
//         proofId: uint256(
//           keccak256(
//             abi.encodePacked(
//               response.proofs[0].claims[0].groupId,
//               response.proofs[0].claims[0].groupTimestamp,
//               response.appId,
//               response.namespace
//             )
//           )
//         ),
//         proofData: response.proofs[0].proofData,
//         extraData: response.proofs[0].claims[0].extraData
//       });
//       // verifiedClaim = VerifiedClaim({
//       //   claimType: ClaimType.GTE,
//       //   groupId: bytes16("groupId"),
//       //   groupTimestamp: bytes16("latest"),
//       //   value: 1,
//       //   proofId: 1,
//       //   proofData: "123",
//       //   extraData: ""
//       // });
//     }
//     return (verifiedAuth, verifiedClaim);
//   }
// }
