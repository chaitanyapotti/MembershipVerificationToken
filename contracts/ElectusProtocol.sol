pragma solidity ^0.4.24;


//For truffle compilation, use path zeppelin-solidity/contracts/ownership/Ownable.sol
//For linting purposes, use path zeppelin-solidity/ownership/Ownable.sol
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
import "./Protocol/IElectusProtocol.sol";


contract ElectusProtocol is IERC1261, Ownable, SupportsInterfaceWithLookup {
    struct MemberData{
        bool hasToken;
        bytes32[] data;
    }

    mapping(bytes32 => bytes32[]) public attributeValueCollection;

    bytes32[] public attributeNames;

    mapping(address => MemberData) public currentHolders;

    address[] public allHolders;

    event Assigned(address indexed to);
    event Revoked(address indexed to);
    event ModifiedAttributes(address indexed to);

    constructor () public {
        supportedInterfaces[0x912f7bb2] = true; //IERC1261
        supportedInterfaces[0x83adfb2d] = true; //Ownable
        //attributeNames = ["hello", "world"];
    }

    modifier isCurrentHolder {
        require(isCurrentMember(msg.sender), "Not a current member");
        _;
    }

    modifier isNotACurrentHolder {
        require(!isCurrentMember(msg.sender), "Already a member");
        _;
    }

    function isCurrentMember(address _to) public view returns (bool){
        require(_to != address(0), "Zero address can't be a member");
        return currentHolders[_to].hasToken;
    }

    function getAllMembers() external view returns (address[]) {
        return allHolders;
    }

    function totalMemberCount() external view returns (uint) {
        return allHolders.length;
    }

    function getAttributeNames() external view returns (bytes32[]) {
        return attributeNames;
    }

    function getAttributes(address _to) external view returns (bytes32[]) {
        require(_to != address(0));
        return currentHolders[_to].data;
    }

    function getAttributeByName(address _to, bytes32 attribute) external view returns (bytes32) {
        uint index = getIndexOfAttribute(attribute);
        return getAttributeByIndex(_to, index);
    }

    function getAttributeByIndex(address _to, uint _attributeIndex) public view returns (bytes32) {
        require(attributeNames.length > _attributeIndex, "Required attribute doesn't exist");
        return currentHolders[_to].data[_attributeIndex];
    }

    function addAttributeSet(bytes32 _name, bytes32[] values) external {
        attributeNames.push(_name);
        attributeValueCollection[_name] = values;
    }

    function modifyAttributes(address _to, uint[] attributeIndexes) external onlyOwner {
        for(uint index = 0; index < attributeIndexes.length; index++) {
            currentHolders[_to].data.push(attributeValueCollection[attributeNames[index]][attributeIndexes[index]]);
        }
        emit ModifiedAttributes(_to);
    }

    function modifyAttributeByName(address _to, bytes32 attributeName, uint modifiedValueIndex) external onlyOwner {
        modifyAttributeByIndex(_to, getIndexOfAttribute(attributeName), modifiedValueIndex);
    }

    function modifyAttributeByIndex(address _to, uint attributeIndex, uint modifiedValueIndex) public onlyOwner {
        currentHolders[_to].data[attributeIndex] = attributeValueCollection[attributeNames[attributeIndex]][modifiedValueIndex];        
        emit ModifiedAttributes(_to);
    }    

    function requestMembership(uint[] attributeIndexes) external isNotACurrentHolder payable {
        //Do some checks before assigning membership
        _assign(msg.sender, attributeIndexes);
    }

    function revokeMembership() external isCurrentHolder payable {
        _revoke(msg.sender);
    }

    function assignTo(address _to, uint[] attributeIndexes) external onlyOwner {
        _assign(_to, attributeIndexes);
    }

    function revokeFrom(address _from) external onlyOwner {
        _revoke(_from);
    }

    function _assign(address _to, uint[] attributeIndexes) private {
        require(_to != address(0), "Can't assign to zero address");        
        MemberData memory member;
        member.hasToken = true;
        currentHolders[_to] = member;
        for(uint index = 0; index < attributeIndexes.length; index++) {
            currentHolders[_to].data.push(attributeValueCollection[attributeNames[index]][attributeIndexes[index]]);
        }
        allHolders.push(_to);
        emit Assigned(_to);
    }

    function _revoke(address _from) private {
        require(_from != address(0), "Can't revoke from zero address");
        MemberData storage member = currentHolders[_from];
        member.hasToken = false;
        emit Revoked(_from);
    }
    
    function getIndexOfAttribute(bytes32 attribute) internal view returns (uint) {
        uint index = 0;
        bool isAttributeFound = false;
        for(uint i = 0; i < attributeNames.length; i++) {
            if(attributeNames[i] == attribute) {
                index = i;
                isAttributeFound = true;
                break;
            }
        }
        require(isAttributeFound, "Invalid Attribute Name");
        return index;
    }
}