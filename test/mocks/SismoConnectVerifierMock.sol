// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../../src/interfaces/ISismoConnectVerifier.sol";

contract SismoConnectVerifierMock is ISismoConnectVerifier {
  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable SISMO_CONNECT_VERSION = "sismo-connect-v1.1";

  bool public isProofValid = true;

  // struct to store informations about the number of verified auths and claims returned
  // indexes of the first available slot in the arrays of auths and claims are also stored
  // this struct is used to avoid stack to deep errors without using via_ir in foundry
  struct VerifiedArraysInfos {
    uint256 nbOfAuths; // number of verified auths
    uint256 nbOfClaims; // number of verified claims
    uint256 authsIndex; // index of the first available slot in the array of verified auths
    uint256 claimsIndex; // index of the first available slot in the array of verified claims
  }

  // Struct holding the verified Auths and Claims from the snark proofs
  // This struct is used to avoid stack too deep error
  struct VerifiedProofs {
    VerifiedAuth[] auths;
    VerifiedClaim[] claims;
  }

  error InvalidProof();

  function setIsProofValid(bool _isProofValid) external {
    isProofValid = _isProofValid;
  }

  function verify(
    SismoConnectResponse memory response,
    SismoConnectRequest memory, // request
    SismoConnectConfig memory // config
  ) external view override returns (SismoConnectVerifiedResult memory) {
    if (!isProofValid) {
      revert InvalidProof();
    }

    uint256 responseProofsArrayLength = response.proofs.length;
    VerifiedArraysInfos memory infos = VerifiedArraysInfos({
      nbOfAuths: 0,
      nbOfClaims: 0,
      authsIndex: 0,
      claimsIndex: 0
    });

    // Count the number of auths and claims in the response
    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      infos.nbOfAuths += response.proofs[i].auths.length;
      infos.nbOfClaims += response.proofs[i].claims.length;
    }

    VerifiedProofs memory verifiedProofs = VerifiedProofs({
      auths: new VerifiedAuth[](infos.nbOfAuths),
      claims: new VerifiedClaim[](infos.nbOfClaims)
    });

    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      // we use an external call to getVerifiedAuthAndClaim to avoid stack too deep error (the caller stack is not known by the callee contract)
      // in the prod implementation, an external call to a verifier contract is done
      // it explains why we don't encounter the stack too deep error in the prod implementation
      (VerifiedAuth memory verifiedAuth, VerifiedClaim memory verifiedClaim) = this
        .getVerifiedAuthAndClaim({
          appId: response.appId,
          namespace: response.namespace,
          proof: response.proofs[i]
        });

      // we only want to add the verified auths and claims to the result
      // if they are not empty, for that we check the length of the proofData that should always be different from 0
      if (verifiedAuth.proofData.length != 0) {
        verifiedProofs.auths[infos.authsIndex] = verifiedAuth;
        infos.authsIndex++;
      }
      if (verifiedClaim.proofData.length != 0) {
        verifiedProofs.claims[infos.claimsIndex] = verifiedClaim;
        infos.claimsIndex++;
      }
    }

    return
      SismoConnectVerifiedResult({
        appId: response.appId,
        namespace: response.namespace,
        version: response.version,
        auths: verifiedProofs.auths,
        claims: verifiedProofs.claims,
        signedMessage: response.signedMessage
      });
  }

  function getVerifiedAuthAndClaim(
    bytes16 appId,
    bytes16 namespace,
    SismoConnectProof memory proof
  ) external pure returns (VerifiedAuth memory, VerifiedClaim memory) {
    VerifiedAuth memory verifiedAuth;
    VerifiedClaim memory verifiedClaim;

    if (proof.auths.length != 0) {
      verifiedAuth = VerifiedAuth({
        authType: proof.auths[0].authType,
        isAnon: proof.auths[0].isAnon,
        userId: proof.auths[0].userId,
        proofData: proof.proofData,
        extraData: proof.auths[0].extraData
      });
    }
    if (proof.claims.length != 0) {
      verifiedClaim = VerifiedClaim({
        claimType: proof.claims[0].claimType,
        groupId: proof.claims[0].groupId,
        groupTimestamp: proof.claims[0].groupTimestamp,
        value: proof.claims[0].value,
        proofId: uint256(
          keccak256(
            abi.encodePacked(
              proof.claims[0].groupId,
              proof.claims[0].groupTimestamp,
              appId,
              namespace
            )
          )
        ),
        proofData: proof.proofData,
        extraData: proof.claims[0].extraData
      });
    }
    return (verifiedAuth, verifiedClaim);
  }
}
