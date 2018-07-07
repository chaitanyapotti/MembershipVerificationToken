pragma solidity ^0.4.24;


contract IElectusProtocol {
    string public name;
    string public symbol;

    event Assigned(address to);
    event Revoked(address to);

    function getAddressAtIndex(uint256 index) public view returns (address);
    function assign(address to) public;
    function revoke(address to) public;
}