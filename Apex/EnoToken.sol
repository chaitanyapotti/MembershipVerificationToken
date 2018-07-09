pragma solidity ^0.4.24;

import "../Protocol/IElectusProtocol.sol";
import "../Ownership/Ownable.sol";


contract EnoToken is IElectusProtocol, Ownable {

    mapping (address => uint256) public currentHolders;

    mapping (uint256 => address) public indexers;

    uint256 public topIndex = 0;

    modifier isCurrentHolder {
        require(isCurrentMember(msg.sender), "The user is not a current member");
        _;
    }

    function isCurrentMember(address to) public view returns (bool) { 
        return currentHolders[to] == 1;
    }

    function getAddressAtIndex(uint256 index) public view returns (address) {
        return indexers[index];
    }

    function assignMembership(address to) public onlyOwner {
        require(currentHolders[to] != 1, "The user is a current member");
        currentHolders[to] = 1;
        indexers[topIndex] = to;
        topIndex++;
        emit Assigned(to);
    }

    function revokeMembership(address to) public {
        require(currentHolders[to] == 1, "The user is not a current member");
        require(to == msg.sender || msg.sender == owner, "Not enough rights");
        currentHolders[to] = 0;
        emit Revoked(to);
    }
}