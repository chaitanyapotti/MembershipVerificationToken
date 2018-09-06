pragma solidity ^0.4.24;
//To be deployed along with Ownable.
//This contract won't change with time. Hence, no interface for it
import "./Ownable.sol";


contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Not enough rights");
        _;
    }

    function isAuthorized(address sender) public view returns (bool) {
        return authorized[sender] || owner == sender;
    }

    function addAuthorized(address _toAdd) public onlyOwner {
        require(_toAdd != 0);
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != 0);
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }

}