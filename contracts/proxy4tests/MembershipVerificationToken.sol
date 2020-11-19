import "../MembershipVerificationToken.sol";

contract ProxyMembershipVerificationToken is MembershipVerificationToken {
    constructor() public {}
    function test_assign(address _to, uint256[] _attributeIndexes) public {
        _assign(_to, _attributeIndexes);
    }

    function test_revoke(address _from) public {
        _revoke(_from);
    }

}
