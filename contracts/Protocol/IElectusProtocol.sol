pragma solidity ^0.4.24;


interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title ERC-173 Contract Ownership Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
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

//todo: add interoperability with other membership tokens
//All other contracts must use a 1300 token which implements this protocol - only reference
interface ERC1261 /* is ERC173, ERC165 */ {

    event Assigned(address indexed to);
    event Revoked(address indexed to);
    
    function isCurrentMember(address to) external view returns (bool);
    function getAllMembers() external view returns (address[]);
    function totalMemberCount() external view returns (uint);
    function getData(address _to) external view returns (bytes32[]);
    function modifyData(address _to, bytes32[] newData) external;
    function requestMembership(bytes32[] data) external payable;
    function revokeMembership() external payable;
    function assignTo(address _to, bytes32[] data) external;
    function revokeFrom(address _from) external;
}

/// @title ERC-1261 Membership Verification Token Standard, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
///  Note: the ERC-1261 identifier for this interface is //TODO.
interface ERC1261Metadata /* is ERC1261 */ {
    /// @notice A descriptive name for a collection of MTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for MTs in this contract
    function symbol() external view returns (string _symbol);
}