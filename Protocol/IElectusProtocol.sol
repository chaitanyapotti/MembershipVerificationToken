pragma solidity ^0.4.24;


//todo: add interoperability with other membership tokens
//All other contracts must use a 1300 token which implements this protocol - only reference
interface ERC1261 /* is ERC165 */ {

    event Assigned(address indexed to);
    event Revoked(address indexed to);
    
    function isCurrentMember(address to) external view returns (bool);
    function getAllMembers() external view returns (address[]);
    function totalMemberCount() external view returns (uint);
    function requestMembership(bytes32[] data) external payable;
    function revokeMembership() external payable;
    function assignTo(address _to, bytes32[] data) external;
    function revokeFrom(address _from) external;
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

/// @title ERC-1261 Membership Verification Token Standard, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
///  Note: the ERC-1261 identifier for this interface is //TODO.
interface ERC1261Metadata /* is ERC1261 */ {
    /// @notice A descriptive name for a collection of MTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for MTs in this contract
    function symbol() external view returns (string _symbol);
}

//TODO: add attributes

//request change of attribute. Approve change of attribute by admin
//bytes[] 
//Log revoke date - 