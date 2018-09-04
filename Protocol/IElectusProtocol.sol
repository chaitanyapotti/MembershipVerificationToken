pragma solidity ^0.4.24;


//TODO: Request transfer of badge - with event
//todo: add interoperability with other membership tokens
// sign message and sent over http request. - assign membership
//todo: add totalsupply()
//todo: add metadata
//All other contracts must use a 1300 token which implements this protocol - only reference
interface IElectusProtocol {

    event Assigned(address indexed to);
    event Revoked(address indexed to);
    
    function canReceiveMembership(address to) external payable;

    function assignTo() external payable;
    function revokeFrom() external payable;
    function assign(address to) external;
    function revoke(address to) external;
    function isCurrentMember(address to) external view returns (bool);
    function getAllMembers() external view returns (address[]);
    function transferRights(address to) external view returns(bool);
}
//TODO: add attributes
//when sending array as input, use external functions.
//TODO: Send in array as input for assign and revoke .. to do batch transactions.

//TODO: Add erc721 attributes - ERC721TokenMetaData - implementation (e.g.: name, symbol)
//TODO: ERC 1261 Wallet implementation
//Refer here while implementing: https://github.com/0xcert/ethereum-erc721

//erc1261 must use erc165.

//request change of attribute. Approve change of attribute by admin
//bytes[] 
//Log revoke date - 