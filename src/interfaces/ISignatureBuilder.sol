// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SignatureRequest} from "../utils/Structs.sol";

interface ISignatureBuilder {
  function build(bytes memory message) external pure returns (SignatureRequest memory);

  function build(
    bytes memory message,
    bool isSelectableByUser
  ) external pure returns (SignatureRequest memory);

  function build(
    bytes memory message,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory);

  function build(
    bytes memory message,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory);

  function build(bool isSelectableByUser) external pure returns (SignatureRequest memory);

  function build(
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory);

  function buildEmpty() external pure returns (SignatureRequest memory);
}
