pragma solidity ^0.4.25;

import "./MembershipVerificationToken.sol";
import "./Protocol/IERC1261.sol";

contract ERC1261MetaData is MembershipVerificationToken, IERC1261Metadata {
    bytes32 internal orgName;
    bytes32 internal orgSymbol;

    constructor(bytes32 _orgName, bytes32 _orgSymbol) public {
        _registerInterface(0x93254542);
        //_supportedInterfaces[0x93254542] = true;
        orgName = _orgName;
        orgSymbol = _orgSymbol;
    }

    function name() external view returns (bytes32) {
        return orgName;
    }

    function symbol() external view returns (bytes32) {
        return orgSymbol;
    }
}
