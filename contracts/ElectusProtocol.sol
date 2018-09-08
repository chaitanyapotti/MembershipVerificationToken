pragma solidity ^0.4.24;


//For truffle compilation, use path zeppelin-solidity/contracts/ownership/Ownable.sol
//For linting purposes, use path zeppelin-solidity/ownership/Ownable.sol
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
import "./Protocol/IElectusProtocol.sol";


contract ElectusProtocol is IERC1261, Ownable, SupportsInterfaceWithLookup {
    struct MemberData{
        bool hasToken;
        bytes32[] data;
    }

    mapping(address => MemberData) public currentHolders;

    address[] public allHolders;

    event Assigned(address indexed to);
    event Revoked(address indexed to);

    constructor () public {
        supportedInterfaces[0x912f7bb2] = true; //IERC1261
        supportedInterfaces[0x83adfb2d] = true; //Ownable
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
        return currentHolders[_to].hasToken;
    }

    function getAllMembers() external view returns (address[]) {
        return allHolders;
    }

    function totalMemberCount() external view returns (uint) {
        return allHolders.length;
    }

    function getData(address _to) external view returns (bytes32[]) {
        return currentHolders[_to].data;
    }

    function modifyData(address _to, bytes32[] newData) external onlyOwner {
        currentHolders[_to].data = newData;
    }

    function requestMembership(bytes32[] data) external isNotACurrentHolder payable {
        //Do some checks before assigning membership
        _assign(msg.sender, data);
    }

    function revokeMembership() external isCurrentHolder payable {
        _revoke(msg.sender);
    }

    function assignTo(address _to, bytes32[] data) external onlyOwner {
        _assign(_to, data);
    }

    function revokeFrom(address _from) external onlyOwner {
        _revoke(_from);
    }

    function _assign(address _to, bytes32[] data) private {
        MemberData memory member = MemberData({hasToken: true, data: data});
        currentHolders[_to] = member;
        allHolders.push(_to);
        emit Assigned(_to);
    }

    function _revoke(address _from) private {
        MemberData storage member = currentHolders[_from];
        member.hasToken = false;
        emit Revoked(_from);
    }    
}