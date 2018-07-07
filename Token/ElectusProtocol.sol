pragma solidity ^0.4.21;

import "./IElectusProtocol.sol";


contract  ElectusProtocol is IElectusProtocol {

    address public owner;

    mapping (address => uint256) public currentHolders;

    mapping (uint256 => address) public indexers;

    uint256 topIndex = 0;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isCurrentHolder {
        require(currentHolders[msg.sender] == 1, "The user is not a current Holder");
        _;
    }

    function getAddressAtIndex(uint256 index) public view returns (address) {
        return indexers[index];
    }

    function assign(address to) public onlyOwner {
        require(currentHolders[to] != 1, "The user is a current token Holder");
        currentHolders[to] = 1;
        indexers[topIndex] = to;
        topIndex++;
        emit Assigned(to);
    }

    function revoke(address to) public {
        require(currentHolders[to] == 1, "The user is not a current token holder");
        currentHolders[to] = 0;
        emit Revoked(to);
    }

    function changeOwnership(address from, address to) public onlyOwner {
        revoke(to);
        assign(from);
    }

}