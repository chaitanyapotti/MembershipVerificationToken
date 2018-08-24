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
    interface ERC1261 {
        /// @dev This emits when a token is assigned to a member.
        event Assigned(address _to);

        /// @dev This emits when a membership is revoked
        event Revoked(address _to);

        /// @dev MVT's assigned to the zero address are considered invalid, and this
        ///  function throws for queries about the zero address.
        /// @param _owner An address for whom to query the membership
        /// @return whether the member owns the token
        function isCurrentMember(address _to) external view returns (bool);

        /// @notice Find the member of an MVT
        /// @dev index starts from zero. Useful to query all addresses (past or present)
        /// @param _tokenId The index
        /// @return The address of the owner of the IVM contract
        function getAddressAtIndex(uint256 _index) external view returns (address);

        /// @notice Assigns membership of an MVT from owner address to another address
        /// @dev Throws if the member already has the token.
        ///  Throws if `_to` is the zero address.
        ///  Throws if the `msg.sender` is not an owner.
        ///  The entity assigns the membership to each individual.
        ///  When transfer is complete, this function emits the Assigned event.
        /// @param _to The member
        function assign(address _to) external;

        /// @notice Requests membership from any address
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
        /// @param _from The current owner of the MVT
        function revoke(address _from) external;

        /// @notice Revokes membership from any address
        /// @dev Throws if the `msg.sender` already doesn't have the token.
        ///  the individual `msg.sender` can revoke his/her membership.
        ///  When transfer is complete, this function emits the Revoked event.
        function revokeFrom() external payable;
    }


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


This is the "ERC1261 Metadata JSON Schema" referenced above.

.. code-block:: json

    {
        "title": "Organization Metadata",
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "Identifies the organization to which this MVT represents",
            },
            "description": {
                "type": "string",
                "description": "Describes the organization to which this MVT represents",
            }
        }
    }


Sample Implementation
=====================

The complete implementation is available at the `github repo <https://github.com/chaitanyapotti/ElectusProtocol/>`_

::

    pragma solidity ^0.4.24;

    import "../Protocol/IElectusProtocol.sol";
    import "../Ownership/Ownable.sol";


    contract VaultToken is IElectusProtocol, Ownable {    

        mapping (address => uint256) public currentHolders;

        mapping (uint256 => address) public indexers;

        uint256 public topIndex = 0;

        mapping (string => address) public uniqueIds;

        modifier isCurrentHolder {
            require(currentHolders[msg.sender] == 1, "The user is not a current member");
            _;
        }

        function isCurrentMember(address to) public view returns (bool) { 
            return currentHolders[to] == 1;
        }

        function getAddressAtIndex(uint256 index) public view returns (address) {
            return indexers[index];
        }

        function assignTo(address to) public payable {
            require(currentHolders[to] != 1, "The user is a current member");
            //Optional ToDo: Call API smart contract to verify ID
            currentHolders[to] = 1;
            indexers[topIndex] = to;
            topIndex++;
            emit Assigned(to);
        }
        
        function assign(address to) public onlyOwner {
            require(currentHolders[to] != 1, "The user is a current member");
            currentHolders[to] = 1;
            indexers[topIndex] = to;
            topIndex++;
            emit Assigned(to);
        }

        function revoke(address to) public {
            require(currentHolders[to] == 1, "The user is not a current member");
            require(to == msg.sender || msg.sender == owner, "Not enough rights");
            currentHolders[to] = 0;
            emit Revoked(to);
        }
        
        function revokeFrom(address to) public payable {
            require(currentHolders[to] == 1, "The user is not a current member");
            require(to == msg.sender || msg.sender == owner, "Not enough rights");
            //TODO: Call API to verify
            currentHolders[to] = 0;
            emit Revoked(to);
        }
    }
