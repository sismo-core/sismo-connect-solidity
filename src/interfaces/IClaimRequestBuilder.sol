// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ClaimRequest, ClaimType} from "../utils/Structs.sol";

interface IClaimRequestBuilder {
  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(bytes16 groupId) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp
  ) external pure returns (ClaimRequest memory);

  function build(bytes16 groupId, uint256 value) external pure returns (ClaimRequest memory);

  function build(bytes16 groupId, ClaimType claimType) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory);

  // allow dev to choose for isOptional
  // we force to also set isSelectableByUser
  // otherwise function signatures would be colliding
  // between build(bytes16 groupId, bool isOptional) and build(bytes16 groupId, bool isSelectableByUser)
  // we keep this logic for all function signature combinations

  function build(
    bytes16 groupId,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    uint256 value,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (ClaimRequest memory);
}
