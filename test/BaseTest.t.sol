// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {IAddressesProvider} from "src/interfaces/IAddressesProvider.sol";
import {AddressesProviderMock} from "test/mocks/AddressesProviderMock.sol";
import {SismoConnectVerifierMock} from "test/mocks/SismoConnectVerifierMock.sol";
import {AuthRequestBuilder} from "src/utils/AuthRequestBuilder.sol";
import {ClaimRequestBuilder} from "src/utils/ClaimRequestBuilder.sol";
import {SignatureBuilder} from "src/utils/SignatureBuilder.sol";
import {RequestBuilder} from "src/utils/RequestBuilder.sol";

contract BaseTest is Test {
  address immutable user1 = vm.addr(1);
  address immutable user2 = vm.addr(2);
  address immutable owner = vm.addr(3);
  address public immutable SISMO_ADDRESSES_PROVIDER_V2 = 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;

  SismoConnectVerifierMock sismoConnectVerifier;

  // external libraries
  AuthRequestBuilder authRequestBuilder;
  ClaimRequestBuilder claimRequestBuilder;
  SignatureBuilder signatureBuilder;
  RequestBuilder requestBuilder;

  function setUp() public virtual {
    AddressesProviderMock addressesProviderMock = new AddressesProviderMock();
    sismoConnectVerifier = new SismoConnectVerifierMock();

    // external libraries
    authRequestBuilder = new AuthRequestBuilder();
    claimRequestBuilder = new ClaimRequestBuilder();
    signatureBuilder = new SignatureBuilder();
    requestBuilder = new RequestBuilder();

    vm.etch(SISMO_ADDRESSES_PROVIDER_V2, address(addressesProviderMock).code);

    IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).set(
      address(sismoConnectVerifier),
      string("sismoConnectVerifier-v1.2")
    );
    IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).set(
      address(authRequestBuilder),
      string("authRequestBuilder-v1.1")
    );
    IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).set(
      address(claimRequestBuilder),
      string("claimRequestBuilder-v1.1")
    );
    IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).set(
      address(signatureBuilder),
      string("signatureBuilder-v1.1")
    );
    IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2).set(
      address(requestBuilder),
      string("requestBuilder-v1.1")
    );
  }
}
