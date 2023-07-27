// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AuthRequest, ClaimRequest, SignatureRequest, SismoConnectRequest} from "../utils/Structs.sol";

interface IRequestBuilder {
  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    ClaimRequest memory claim,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest memory auth,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(AuthRequest memory auth) external view returns (SismoConnectRequest memory);

  function build(
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(ClaimRequest memory claim) external view returns (SismoConnectRequest memory);

  // build with arrays for auths and claims
  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims
  ) external view returns (SismoConnectRequest memory);

  function build(
    AuthRequest[] memory auths,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(AuthRequest[] memory auths) external view returns (SismoConnectRequest memory);

  function build(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) external pure returns (SismoConnectRequest memory);

  function build(ClaimRequest[] memory claims) external view returns (SismoConnectRequest memory);
}
