pragma solidity ^0.4.24;

import "../Protocol/IElectusProtocol.sol";
import "../Ownership/Ownable.sol";


contract EnoToken is IElectusProtocol, Ownable {

    mapping (address => uint256) public currentHolders;

    address[] public indexers;

    modifier isCurrentHolder {
        require(isCurrentMember(msg.sender), "The user is not a current member");
        _;
    }

    function isCurrentMember(address to) public view returns (bool) { 
        return currentHolders[to] == 1;
    }

    function getAllMembers() public view returns (address[]) {
        return indexers;
    }

    function assignMembership(address to) public onlyOwner {
        require(currentHolders[to] != 1, "The user is a current member");
        currentHolders[to] = 1;
        indexers.push(to);
        emit Assigned(to);
    }

    function revokeMembership(address to) public {
        require(currentHolders[to] == 1, "The user is not a current member");
        require(to == msg.sender || msg.sender == owner, "Not enough rights");
        currentHolders[to] = 0;
        emit Revoked(to);
    }

    function transferRights(address to) public {
        revokeMembership(msg.sender);
        assignMembership(to);
    }

    function voteInPoll(address pollAddress, uint8 proposal) public onlyOwner {
        BasePoll poll = BasePoll(pollAddress);
        poll.vote(proposal);
    }
}