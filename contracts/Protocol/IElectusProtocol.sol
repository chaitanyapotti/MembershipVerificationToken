pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/introspection/ERC165.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

//todo: add interoperability with other membership tokens
//All other contracts must use a 1300 token which implements this protocol - only reference
interface IERC1261 /* is ERC173, ERC165 */ {

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
interface IERC1261Metadata /* is ERC1261 */ {
    /// @notice A descriptive name for a collection of MTs in this contract
    function name() external view returns (string);

    /// @notice An abbreviated name for MTs in this contract
    function symbol() external view returns (string);
}