// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AuthRequest, AuthType} from "../utils/Structs.sol";

interface IAuthRequestBuilder {
  error InvalidUserIdAndIsSelectableByUserAuthType();
  error InvalidUserIdAndAuthType();

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isOptional,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (AuthRequest memory);

  function build(AuthType authType) external pure returns (AuthRequest memory);

  function build(AuthType authType, bool isAnon) external pure returns (AuthRequest memory);

  function build(AuthType authType, uint256 userId) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bytes memory extraData
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (AuthRequest memory);

  // allow dev to choose for isOptional
  // the user is ask to choose isSelectableByUser to avoid the function signature collision
  // between build(AuthType authType, bool isOptional) and build(AuthType authType, bool isAnon)

  function build(
    AuthType authType,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bool isOptional,
    bool isSelectableByUser,
    uint256 userId
  ) external pure returns (AuthRequest memory);

  // the user is ask to choose isSelectableByUser to avoid the function signature collision
  // between build(AuthType authType, bool isAnon, bool isOptional) and build(AuthType authType, bool isOptional, bool isSelectableByUser)

  function build(
    AuthType authType,
    bool isAnon,
    bool isOptional,
    bool isSelectableByUser
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    uint256 userId,
    bool isOptional
  ) external pure returns (AuthRequest memory);

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isOptional
  ) external pure returns (AuthRequest memory);
}
