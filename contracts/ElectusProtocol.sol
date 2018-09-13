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
        attributeNames.push("hair");
        attributeNames.push("skin");
        attributeNames.push("height");
        attributeValueCollection["hair"].push("black");
        attributeValueCollection["hair"].push("white");
        attributeValueCollection["skin"].push("black");
        attributeValueCollection["skin"].push("white");
        attributeValueCollection["height"].push("1.5");
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

    function getAttributeNames() external view returns (bytes32[]) {
        return attributeNames;
    }

    function getAttributes(address _to) external view returns (bytes32[]) {
        require(_to != address(0));
        return currentHolders[_to].data;
    }

    function getAttributeByName(address _to, bytes32 attribute) external view returns (bytes32) {
        uint index = getIndexOfAttribute(attribute);
        return currentHolders[_to].data[index];
    }

    function addAttributeSet(bytes32 _name, bytes32[] values) external {
        attributeNames.push(_name);
        attributeValueCollection[_name] = values;
    }

    function modifyAttributeByName(address _to, bytes32 _attributeName, uint _modifiedValueIndex) external onlyOwner {
        uint attributeIndex = getIndexOfAttribute(_attributeName);
        currentHolders[_to].data[attributeIndex] = attributeValueCollection[attributeNames[attributeIndex]][_modifiedValueIndex];
        emit ModifiedAttributes(_to);
    }

    function requestMembership(uint[] attributeIndexes) external isNotACurrentHolder payable {
        //Do some checks before assigning membership
        _assign(msg.sender, attributeIndexes);
    }

    function forfeitMembership() external isCurrentHolder payable {
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