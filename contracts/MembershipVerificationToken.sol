pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/introspection/ERC165.sol";
import "./Protocol/IERC1261.sol";


contract MembershipVerificationToken is IERC1261, Ownable, ERC165 {
    struct MemberData {
        bool hasToken;
        bytes32[] data;
    }

    struct PendingRequest {
        bool isPending;
        uint[] attributes;
    }

    mapping(bytes32 => bytes32[]) public attributeValueCollection;

    bytes32[] public attributeNames;

    mapping(address => MemberData) public currentHolders;
    mapping(address => PendingRequest) public pendingRequests;

    address[] public allHolders;

    uint public currentMemberCount;

    event ApprovedMembership(address indexed _to, uint[] attributeIndexes);
    event RequestedMembership(address indexed _to);
    event Assigned(address indexed _to, uint[] attributeIndexes);
    event Revoked(address indexed _to);
    event Forfeited(address indexed _to);
    event ModifiedAttributes(address indexed _to, uint attributeIndex, uint attributeValueIndex);

    constructor () public {
        _registerInterface(0x912f7bb2); //IERC1261
        _registerInterface(0x83adfb2d); //Ownable
    }

    modifier isCurrentHolder {
        require(isCurrentMember(msg.sender), "Not a current member");
        _;
    }

    function requestMembership(uint[] _attributeIndexes) external payable {
        require(!isCurrentMember(msg.sender), "Already a member");
        require(_attributeIndexes.length == attributeNames.length, "Need to input all attributes");
        //Do some checks before assigning membership
        PendingRequest storage request = pendingRequests[msg.sender];
        request.isPending = true;
        request.attributes = _attributeIndexes;
        emit RequestedMembership(msg.sender);
    }

    function forfeitMembership() external isCurrentHolder payable {
        _revoke(msg.sender);
        emit Forfeited(msg.sender);
    }

    function approveRequest(address _user) external onlyOwner {
        PendingRequest storage request = pendingRequests[_user];
        require(request.isPending, "Hasn't sent ether yet");
        _assign(_user, request.attributes);
        emit ApprovedMembership(_user, request.attributes);
    }

    function discardRequest(address _user) external onlyOwner {
        PendingRequest storage request = pendingRequests[_user];
        require(request.isPending, "Hasn't sent ether yet");
        request.isPending = false;
        delete request.attributes;
    }

    function assignTo(address _to, uint[] _attributeIndexes) external onlyOwner {
        _assign(_to, _attributeIndexes);
        emit Assigned(_to, _attributeIndexes);
    }

    function revokeFrom(address _from) external onlyOwner {
        _revoke(_from);
        emit Revoked(_from);
    }

    function addAttributeSet(bytes32 _name, bytes32[] values) external {
        attributeNames.push(_name);
        attributeValueCollection[_name] = values;
    }

    function modifyAttributeByIndex(address _to, uint _attributeIndex, uint _modifiedValueIndex) external onlyOwner {
        // uint attributeIndex = getIndexOfAttribute(_attributeName);
        require(currentHolders[_to].data.length > _attributeIndex, "data doesn't exist for the user");
        currentHolders[_to].data[_attributeIndex] = attributeValueCollection[attributeNames[_attributeIndex]]
        [_modifiedValueIndex];
        emit ModifiedAttributes(_to, _attributeIndex, _modifiedValueIndex);
    }

    function getAllMembers() external view returns (address[]) {
        return allHolders;
    }

    function getCurrentMemberCount() external view returns (uint) {
        return currentMemberCount;
    }

    function getAttributeNames() external view returns (bytes32[]) {
        return attributeNames;
    }

    function getAttributes(address _to) external view returns (bytes32[]) {
        require(_to != address(0));
        return currentHolders[_to].data;
    }

    function getAttributeExhaustiveCollection(bytes32 _name) external view returns (bytes32[]) {
        return attributeValueCollection[_name];
    }

    function getAttributeByIndex(address _to, uint _attributeIndex) external view returns (bytes32) {
        require(currentHolders[_to].data.length > _attributeIndex, "data doesn't exist for the user");
        return currentHolders[_to].data[_attributeIndex];
    }

    function isCurrentMember(address _to) public view returns (bool) {
        require(_to != address(0), "Zero address can't be a member");
        return currentHolders[_to].hasToken;
    }
    
    function _assign(address _to, uint[] _attributeIndexes) internal {
        require(_to != address(0), "Can't assign to zero address");        
        require(_attributeIndexes.length == attributeNames.length, "Need to input all attributes");
        MemberData memory member;
        member.hasToken = true;
        currentHolders[_to] = member;
        for (uint index = 0; index < _attributeIndexes.length; index++) {
            currentHolders[_to].data.push(attributeValueCollection[attributeNames[index]][_attributeIndexes[index]]);
        }
        allHolders.push(_to);
        currentMemberCount += 1;
    }

    function _revoke(address _from) internal {
        require(_from != address(0), "Can't revoke from zero address");
        MemberData storage member = currentHolders[_from];
        member.hasToken = false;
        currentMemberCount -= 1;
    }
}