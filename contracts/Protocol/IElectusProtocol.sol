pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/introspection/ERC165.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

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

    /// @notice Returns the list of all attribute names
    /// @dev Returns the names of attributes as a bytes32 array. 
    ///  Use web3.toAscii(data[0]).replace(/\u0000/g, "") to convert to string in JS.
    /// @return the names of attributes
    function getAttributeNames() external view returns (bytes32[]);

    /// @notice Returns the attributes of `_to` address.
    /// @dev Throws if `_to` is the zero address.
    ///  returns the attributes associated with `_to` address.
    ///  Use web3.toAscii(data[0]).replace(/\u0000/g, "") to convert to string in JS.
    /// @return the attributes associated with `_to` address.
    function getAttributes(address _to) external view returns (bytes32[]);

    /// @notice returns the attribute at `attributeIndex` stored against `_to` address
    /// @dev Throws if the attribute index is out of bounds.
    ///  returns the attribute at the specified index.
    /// @return the attribute at the specified index.
    function getAttributeByIndex(address _to, uint attributeIndex) external view returns (bytes32);

    /// @notice returns the `attribute` stored against `_to` address
    /// @dev Finds the index of the `attribute`
    ///  Throws if the attribute is not present in the predefined attributes
    /// @return the attribute at the specified name
    function getAttributeByName(address _to, bytes32 attribute) external view returns (bytes32);

    
    function addAttributeSet(bytes32 _name, bytes32[] values) external;
    ///  Use appropriate checks for whether a user/admin can modify the data.
    ///  Best practice is to use onlyOwner modifier from ERC173.
    function modifyAttributes(address _to, uint[] attributeIndexes) external;

    function modifyAttributeByName(address _to, bytes32 attributeName, uint modifiedValueIndex) external;

    function modifyAttributeByIndex(address _to, uint attributeIndex, uint modifiedValueIndex) external;

    /// @notice Requests membership from any address.
    /// @dev Throws if the `msg.sender` already has the token.
    ///  the individual `msg.sender` can request for a membership and if some exisiting criteria are satisfied,
    ///  the individual `msg.sender` receives the token.
    ///  When the token is assigned, this function emits the Assigned event.
    /// @param data the data associated with the member.
    function requestMembership(uint[] data) external payable;

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
    function assignTo(address _to, uint[] data) external;

    /// @notice Only Owner can revoke the membership
    /// @dev This removes the membership of the user.
    ///  Throws if the `_from` is not an owner of the token.
    ///  Throws if the `msg.sender` is not an owner.
    ///  Throws if `_from` is the zero address.
    ///  When transaction is complete, this function emits the Revoked event.
    /// @param _from The current owner of the MVT.
    function revokeFrom(address _from) external;
}

/// @title ERC-1261 Membership Verification Token Standard, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
///  Note: the ERC-1261 identifier for this interface is 0x93254542.
interface IERC1261Metadata /* is ERC1261 */ {
    /// @notice A descriptive name for a collection of MTs in this contract.
    function name() external view returns (string);

    /// @notice An abbreviated name for MTs in this contract.
    function symbol() external view returns (string);
}