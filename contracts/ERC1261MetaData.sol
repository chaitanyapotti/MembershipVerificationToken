pragma solidity ^0.4.25;

import "./ElectusProtocol.sol";
import "./Protocol/IElectusProtocol.sol";


contract ERC1261MetaData is ElectusProtocol, IERC1261Metadata {

    bytes32 internal orgName;
    bytes32 internal orgSymbol;
    
    constructor(bytes32 _orgName, bytes32 _orgSymbol) public {
        supportedInterfaces[0x93254542] = true;
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