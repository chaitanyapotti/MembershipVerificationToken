---
eip: 1300
title: ERC-1300 
author: Chaitanya Potti <chaitanya@electus.network>, Partha Bhattacharya <partha@electus.network>
type: Standards Track
category: ERC
status: Initial
created: 2018-07-14
requires: 
---

## Simple Summary

A standard interface for Membership Token(MT).

## Abstract

The following standard allows for the implementation of a standard API for Membership Token within smart contracts. This standard provides basic functionality to track memberships.

We considered use cases of membership tokens being assigned to individuals which are non-transferable and revokable by the owner. MTs can represent proof of identity. We considered a diverse universe of usecases, and we know you will dream up many more:

- Voting - only members with tokens can vote
- Passport issuance, social benefit distribution, Unique Identity
- Shareholder, organizational member
- login

In general, an individual can have different memberships in his day to day life. The protocol puts them all at one place. His membership can be verified instantly. Imagine a world where you don't need to carry a wallet full of membership cards (Passport, gym membership, SSN, Company ID etc) and organizations can easily keep track of all its members. Organizations can easily identify and disallow fake identities.

## Motivation

A standard interface allows any user,applications to work with any MT on Ethereum. We provide for simple ERC-1300 smart contracts. Additional applications are discussed below.

This standard is inspired from the fact that ERC 20 tradable tokens must be kept separate from voting right tokens. Elaborating, 
///TODO:

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

**Every ERC-1300 compliant contract must implement the `ERC1300` interface:

```solidity
pragma solidity ^0.4.24;

/// @title ERC-1300 Membership Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1300.md
interface ERC1300 {
    /// @dev This emits when a token is assigned to a member.
    event Assigned(address _to);

    /// @dev This emits when a membership is revoked
    event Revoked(address _to);

    /// @dev MTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the membership
    /// @return whether the member owns the token
    function isCurrentMember(address _to) external view returns (bool);

    /// @notice Find the member of an MT
    /// @dev index starts from zero. Useful to query all addresses (past or present)
    /// @param _tokenId The index
    /// @return The address of the owner of the MT
    function getAddressAtIndex(uint256 _index) external view returns (address);

    /// @notice Assigns membership of an MT from owner address to another address
    /// @dev Throws if the member already has the token.
    ///  Throws if `_to` is the zero address.
    ///  Throws if the `msg.sender` is not an owner.
    ///  The entity assigns the membership to each individual.
    ///  When transfer is complete, this function emits the Assigned event.
    /// @param _to The member
    function assign(address _to) external;

    /// @notice Requests membership of an MT from any address
    /// @dev Throws if the `msg.sender` already has the token.
    ///  the individual `msg.sender` can request for a membership and if some exisiting criteria are satisfied,
    ///  the individual `msg.sender` receives the token.
    ///  When transfer is complete, this function emits the Assigned event.
    function assignTo() external payable;

    /// @notice Revokes the membership
    /// @dev This removes the membership of the user.
    ///  Throws if the `_from` is not an owner of the token.
    ///  Throws if the `msg.sender` is not an owner.
    ///  Throws if `_from` is the zero address.
    ///  When transaction is complete, this function emits the Revoked event.
    /// @param _from The current owner of the NFT
    function revoke(address _from) external;

    /// @notice Revokes membership of an MT from any address
    /// @dev Throws if the `msg.sender` already doesn't have the token.
    ///  the individual `msg.sender` can revoke his/her membership.
    ///  When transfer is complete, this function emits the Revoked event.
    function revokeFrom() external payable;
}

```

The **metadata extension** is OPTIONAL for ERC-1300 smart contracts (see "caveats", below). This allows your smart contract to be interrogated for its name and for details about the organization which your MTs represent.

```solidity
/// @title ERC-1300 Membership Token Standard, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1300.md
interface ERC1300Metadata /* is ERC1300 */ {
    /// @notice A descriptive name for a collection of MTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for MTs in this contract
    function symbol() external view returns (string _symbol);
}
```

This is the "ERC1300 Metadata JSON Schema" referenced above.

```json
{
    "title": "Organization Metadata",
    "type": "object",
    "properties": {
        "name": {
            "type": "string",
            "description": "Identifies the organization to which this MT represents",
        },
        "description": {
            "type": "string",
            "description": "Describes the organization to which this MT represents",
        }
    }
}
```

### Caveats

The 0.4.24 Solidity interface grammar is not expressive enough to document the ERC-721 standard. A contract which complies with ERC-721 MUST also abide by the following:

- Solidity issue #3412: The above interfaces include explicit mutability guarantees for each function. Mutability guarantees are, in order weak to strong: `payable`, implicit nonpayable, `view`, and `pure`. Your implementation MUST meet the mutability guarantee in this interface and you MAY meet a stronger guarantee. For example, a `payable` function in this interface may be implemented as nonpayble (no state mutability specified) in your contract. We expect a later Solidity release will allow your stricter contract to inherit from this interface, but a workaround for version 0.4.24 is that you can edit this interface to add stricter mutability before inheriting from your contract.
- Solidity issue #3419: A contract that implements `ERC1300Metadata` SHALL also implement `ERC1300`.
- Solidity issue #2330: If a function is shown in this specification as `external` then a contract will be compliant if it uses `public` visibility. As a workaround for version 0.4.24, you can edit this interface to switch to `public` before inheriting from your contract.
- Solidity issues #3494, #3544: Use of `this.*.selector` is marked as a warning by Solidity, a future version of Solidity will not mark this as an error.

*If a newer version of Solidity allows the caveats to be expressed in code, then this EIP MAY be updated and the caveats removed, such will be equivalent to the original specification.*

## Rationale

There are many proposed uses of Ethereum smart contracts that depend on tracking membership. Examples of existing or planned MTs are Electus Token in ElectusNetwork. Future uses include tracking real-world identities, like passports, SSN and other memberships

**"MT" Word Choice**
///TODO

///TODO *Alternatives considered: ticket*

**Transfer Mechanism**

Membership can't be transferred.

**Assign and Revoke mechanism**

The assign and revoke functions' documentation only specify conditions when the transaction MUST throw. Your implementation MAY also throw in other situations. This allows implementations to achieve interesting results:

- **Disallow additional memberships after a condition is met** — Sample contract found on Electus Protocol
- **Blacklist certain address from receiving Mts** — Sample contract found on Electus Protocol
- **Disallow additional memberships after a certain time is reached** — Sample contract found on Electus Protocol
- **Charge a fee to user of a transaction** — require payment when calling `assign` and `revoke` so that condition checks from external sources can be made

**Gas and Complexity** (regarding the enumeration extension)

This specification contemplates implementations that manage a few and *arbitrarily large* numbers of MTs. If your application is able to grow then avoid using for/while loops in your code. These indicate your contract may be unable to scale and gas costs will rise over time without bound

**Privacy**

//TODO

**Metadata Choices** (metadata extension)

We have required `name` and `symbol` functions in the metadata extension. Every token EIP and draft we reviewed (ERC-20, ERC-223, ERC-677, ERC-777, ERC-827) included these functions.

We remind implementation authors that the empty string is a valid response to `name` and `symbol` if you protest to the usage of this mechanism. We also remind everyone that any smart contract can use the same name and symbol as *your* contract. How a client may determine which ERC-1300 smart contracts are well-known (canonical) is outside the scope of this standard.

A mechanism is provided to associate MTs with URIs. We expect that many implementations will take advantage of this to provide metadata for each MT. The URI MAY be mutable (i.e. it changes from time to time). We considered an MT representing membership of a place, in this case metadata about the organization can naturally change.

Metadata is returned as a string value. Currently this is only usable as calling from `web3`, not from other contracts. This is acceptable because we have not considered a use case where an on-blockchain application would query such information.

*Alternatives considered: put all metadata for each asset on the blockchain (too expensive), use URL templates to query metadata parts (URL templates do not work with all URL schemes, especially P2P URLs), multiaddr network address (not mature enough)*

**Community Consensus**

We have been very inclusive in this process and invite anyone with questions or contributions into our discussion. However, this standard is written only to support the identified use cases which are listed herein.

## Backwards Compatibility

We have adopted `name` and `symbol` semantics from the ERC-20 specification.

Example MT implementations as of July 2018:

- Electus Protocol(Github Link to be added when public //TODO)

## Test Cases

Electus Protocol ERC-1300 Token includes test cases written using Truffle.

## Implementations

Electus Protocol ERC1300 -- a reference implementation

- MIT licensed, so you can freely use it for your projects
- Includes test cases
- Active bug bounty, you will be paid if you find errors

## References

**Standards**

1. ERC-20 Token Standard. https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
1. ERC-173 Owned Standard. https://github.com/ethereum/EIPs/issues/173
1. Ethereum Name Service (ENS). https://ens.domains
1. JSON Schema. http://json-schema.org/
1. Multiaddr. https://github.com/multiformats/multiaddr
1. RFC 2119 Key words for use in RFCs to Indicate Requirement Levels. https://www.ietf.org/rfc/rfc2119.txt

**Issues**

1. The Original ERC-1300 Issue. https://github.com/ethereum/eips/issues/1300
1. Solidity Issue \#2330 -- Interface Functions are Axternal. https://github.com/ethereum/solidity/issues/2330
1. Solidity Issue \#3412 -- Implement Interface: Allow Stricter Mutability. https://github.com/ethereum/solidity/issues/3412
1. Solidity Issue \#3419 -- Interfaces Can't Inherit. https://github.com/ethereum/solidity/issues/3419

**Discussions**

//TODO
1. Reddit (announcement of first live discussion). https://www.reddit.com/r/ethereum/comments/7r2ena/friday_119_live_discussion_on_erc_nonfungible/
1. Gitter #EIPs (announcement of first live discussion). https://gitter.im/ethereum/EIPs?at=5a5f823fb48e8c3566f0a5e7
1. ERC-721 (announcement of first live discussion). https://github.com/ethereum/eips/issues/721#issuecomment-358369377

**NFT Implementations and Other Projects**

1. Electus Protocol ERC-1300 Token. https://github.com/chaitanyapotti/ElectusProtocol

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).