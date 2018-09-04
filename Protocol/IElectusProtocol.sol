pragma solidity ^0.4.24;


//TODO: Add Staking for Electus Protocol - expire staking
//TODO: Add erc721 attributes
//TODO: Request transfer of badge - with event

//All other contracts must use a 1300 token which implements this protocol - only reference
interface IElectusProtocol {
    event Assigned(address to);
    event Revoked(address to);
    
    function assignTo() external payable;
    function revokeFrom() external payable;
    function assign(address to) external;
    function revoke(address to) external;
    function isCurrentMember(address to) external view returns (bool);
    function getAddressAtIndex(uint256 index) external view returns (address);
}