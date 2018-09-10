********************************
Entity Implementation
********************************

Interface
=========

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

**Every ERC-1261 compliant contract must implement the ERC1261 interface:

::


    pragma solidity ^0.4.24;

    /// @title ERC-1261 MVT Standard
    /// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
    ///  Note: the ERC-165 identifier for this interface is 0x912f7bb2.
    interface IERC1261 /* is ERC173, ERC165 */ {
        /// @dev This emits when a token is assigned to a member.
        event Assigned(address indexed to);

        /// @dev This emits when a membership is revoked.
        event Revoked(address indexed to);

        /// @dev This emits when data of a member is modified.
        ///  Doesn't emit when a new membership is created and data is assigned.
        event ModifiedData(address indexed to);

        /// @notice Queries whether a member is a current member of the organization
        /// @dev MVT's assigned to the zero address are considered invalid, and this
        ///  function throws for queries about the zero address.
        /// @param _to An address for whom to query the membership.
        /// @return whether the member owns the token.
        function isCurrentMember(address _to) external view returns (bool);

        /// @notice Returns the list of all past and present members
        /// @dev Use this function along with isCurrentMember to find wasMemberOf() in Js.
        ///  It can be calculated as present in getAllMembers() and !isCurrentMember().
        /// @return List of addresses who have owned the token and currently own the token.
        function getAllMembers() external view returns (address[]);

        /// @dev Returns the count of past and present members.
        /// @return count of members who have owned the token.
        function totalMemberCount() external view returns (uint);

        ///@notice Gets the data associated with a user.
        /// @dev Gets the data associated with a member as a bytes32 Array.
        ///  Use web3.toAscii(data[0]).replace(/\u0000/g, "") to convert to string in JS.
        /// @param _to An address for whom to query the membership.
        /// @return the data associated with the member.
        function getData(address _to) external view returns (bytes32[]);

        /// @notice Modifies the data assoicated with a user.
        /// @dev Input format must be a bytes32 array.
        ///  Use appropriate checks for whether a user/admin can modify the data.
        ///  Best practice include using onlyOwner modifier from ERC173.
        /// @param _to An address for whom to query the membership.
        /// @param newData the new data which is to be stored against the user.
        function modifyData(address _to, bytes32[] newData) external;

        /// @notice Requests membership from any address.
        /// @dev Throws if the `msg.sender` already has the token.
        ///  the individual `msg.sender` can request for a membership and if some exisiting criteria are satisfied,
        ///  the individual `msg.sender` receives the token.
        ///  When the token is assigned, this function emits the Assigned event.
        /// @param data the data associated with the member.
        function requestMembership(bytes32[] data) external payable;

        /// @notice Revokes membership from any address.
        /// @dev Throws if the `msg.sender` already doesn't have the token.
        ///  the individual `msg.sender` can revoke his/her membership.
        ///  When the token is revoked, this function emits the Revoked event.
        function revokeMembership() external payable;

        /// @notice Assigns membership of an MVT from owner address to another address
        /// @dev Throws if the member already has the token.
        ///  Throws if `_to` is the zero address.
        ///  Throws if the `msg.sender` is not an owner.
        ///  The entity assigns the membership to each individual.
        ///  When the token is assigned, this function emits the Assigned event.
        /// @param _to the address to which the token is assigned.
        /// @param data the data associated with the address.
        function assignTo(address _to, bytes32[] data) external;

        /// @notice Only Owner can revoke the membership
        /// @dev This removes the membership of the user.
        ///  Throws if the `_from` is not an owner of the token.
        ///  Throws if the `msg.sender` is not an owner.
        ///  Throws if `_from` is the zero address.
        ///  When transaction is complete, this function emits the Revoked event.
        /// @param _from The current owner of the MVT.
        function revokeFrom(address _from) external;
    }

    interface ERC173 /* is ERC165 */ {
        /// @dev This emits when ownership of a contract changes.
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /// @notice Get the address of the owner
        /// @return The address of the owner.
        function owner() view external;

        /// @notice Set the address of the new owner of the contract
        /// @param _newOwner The address of the new owner of the contract
        function transferOwnership(address _newOwner) external;
    }

    interface ERC165 {
        /// @notice Query if a contract implements an interface
        /// @param interfaceID The interface identifier, as specified in ERC-165
        /// @dev Interface identification is specified in ERC-165. This function
        ///  uses less than 30,000 gas.
        /// @return `true` if the contract implements `interfaceID` and
        ///  `interfaceID` is not 0xffffffff, `false` otherwise
        function supportsInterface(bytes4 interfaceID) external view returns (bool);
    }
```

The metadata extension is OPTIONAL for ERC-1261 smart contracts (see "caveats", below). This allows your smart contract to be interrogated for its name and for details about the organization which your IVM tokens represent.

::

    /// @title ERC-1261 IVM Token Standard, optional metadata extension
    /// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
    interface ERC1261Metadata /* is ERC1261 */ {
        /// @notice A descriptive name for a collection of MVTs in this contract
        function name() external view returns (string _name);

        /// @notice An abbreviated name for MVTs in this contract
        function symbol() external view returns (string _symbol);
    }


The **metadata extension** is OPTIONAL for ERC-1261 smart contracts (see "caveats", below). This allows your smart contract to be interrogated for its name and for details about the organization which your IVM tokens represent.

```solidity
    /// @title ERC-1261 MVT Standard, optional metadata extension
    /// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
    interface ERC1261Metadata /* is ERC1261 */ {
        /// @notice A descriptive name for a collection of MVTs in this contract
        function name() external view returns (string _name);

        /// @notice An abbreviated name for MVTs in this contract
        function symbol() external view returns (string _symbol);
    }
```

This is the "ERC1261 Metadata JSON Schema" referenced above.

```json
{
  "title": "Organization Metadata",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Identifies the organization to which this MVT represents"
    },
    "description": {
      "type": "string",
      "description": "Describes the organization to which this MVT represents"
    }
  }
}
```

### Caveats

The 0.4.24 Solidity interface grammar is not expressive enough to document the ERC-1261 standard. A contract which complies with ERC-1261 MUST also abide by the following:

- Solidity issue #3412: The above interfaces include explicit mutability guarantees for each function. Mutability guarantees are, in order weak to strong: `payable`, implicit nonpayable, `view`, and `pure`. Your implementation MUST meet the mutability guarantee in this interface and you MAY meet a stronger guarantee. For example, a `payable` function in this interface may be implemented as nonpayble (no state mutability specified) in your contract. We expect a later Solidity release will allow your stricter contract to inherit from this interface, but a workaround for version 0.4.24 is that you can edit this interface to add stricter mutability before inheriting from your contract.
- Solidity issue #3419: A contract that implements `ERC1261Metadata` SHALL also implement `ERC1261`.
- Solidity issue #2330: If a function is shown in this specification as `external` then a contract will be compliant if it uses `public` visibility. As a workaround for version 0.4.24, you can edit this interface to switch to `public` before inheriting from your contract.
- Solidity issues #3494, #3544: Use of `this.*.selector` is marked as a warning by Solidity, a future version of Solidity will not mark this as an error.

_If a newer version of Solidity allows the caveats to be expressed in code, then this EIP MAY be updated and the caveats removed, such will be equivalent to the original specification._


Sample Implementation
=====================

The complete implementation is available at the `github repo <https://github.com/chaitanyapotti/ElectusProtocol/>`_

::

    pragma solidity ^0.4.24;


    //For truffle compilation, use path zeppelin-solidity/contracts/ownership/Ownable.sol
    //For linting purposes, use path zeppelin-solidity/ownership/Ownable.sol
    import "zeppelin-solidity/contracts/ownership/Ownable.sol";
    import "zeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
    import "./Protocol/IElectusProtocol.sol";


    contract ElectusProtocol is IERC1261, Ownable, SupportsInterfaceWithLookup {
        struct MemberData{
            bool hasToken;
            bytes32[] data;
        }

        mapping(address => MemberData) public currentHolders;

        address[] public allHolders;

        event Assigned(address indexed to);
        event Revoked(address indexed to);
        event ModifiedData(address indexed to);

        constructor () public {
            supportedInterfaces[0x912f7bb2] = true; //IERC1261
            supportedInterfaces[0x83adfb2d] = true; //Ownable
        }

        modifier isCurrentHolder {
            require(isCurrentMember(msg.sender), "Not a current member");
            _;
        }

        modifier isNotACurrentHolder {
            require(!isCurrentMember(msg.sender), "Already a member");
            _;
        }

        function isCurrentMember(address _to) public view returns (bool){
            require(_to != address(0));
            return currentHolders[_to].hasToken;
        }

        function getAllMembers() external view returns (address[]) {
            return allHolders;
        }

        function totalMemberCount() external view returns (uint) {
            return allHolders.length;
        }

        function getData(address _to) external view returns (bytes32[]) {
            require(_to != address(0));
            return currentHolders[_to].data;
        }

        function modifyData(address _to, bytes32[] newData) external onlyOwner {
            currentHolders[_to].data = newData;
            emit ModifiedData(_to);
        }

        function requestMembership(bytes32[] data) external isNotACurrentHolder payable {
            //Do some checks before assigning membership
            _assign(msg.sender, data);
        }

        function revokeMembership() external isCurrentHolder payable {
            _revoke(msg.sender);
        }

        function assignTo(address _to, bytes32[] data) external onlyOwner {
            _assign(_to, data);
        }

        function revokeFrom(address _from) external onlyOwner {
            _revoke(_from);
        }

        function _assign(address _to, bytes32[] data) private {
            require(_to != address(0));
            MemberData memory member = MemberData({hasToken: true, data: data});
            currentHolders[_to] = member;
            allHolders.push(_to);
            emit Assigned(_to);
        }

        function _revoke(address _from) private {
            require(_from != address(0));
            MemberData storage member = currentHolders[_from];
            member.hasToken = false;
            emit Revoked(_from);
        }    
    }