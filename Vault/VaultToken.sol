pragma solidity ^0.4.24;

import "../Protocol/IElectusProtocol.sol";
import "../Ownership/Ownable.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract VaultToken is IElectusProtocol, Ownable, usingOraclize {    

    mapping (address => uint256) public currentHolders;

    mapping (uint256 => address) public indexers;

    uint256 public topIndex = 0;

    mapping (string => address) public uniqueIds;

    modifier isCurrentHolder {
        require(currentHolders[msg.sender] == 1, "The user is not a current member");
        _;
    }

    function isCurrentMember(address to) public view returns (bool) { 
        return currentHolders[to] == 1;
    }

    function getAddressAtIndex(uint256 index) public view returns (address) {
        return indexers[index];
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        //todo: something with result;
        require(uniqueIds[result] != 0x0);
        currentHolders[to] = 1;
        indexers[topIndex] = to;
        topIndex++;
        emit Assigned(to);
    }

    function assignMembership(address to) public payable {
        require(currentHolders[to] != 1, "The user is a current member");
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(//TODO:API).Value");
        }
    }

    function revokeMembership(address to) public {
        require(currentHolders[to] == 1, "The user is not a current member");
        require(to == msg.sender || msg.sender == owner, "Not enough rights");
        currentHolders[to] = 0;
        emit Revoked(to);
    }
}