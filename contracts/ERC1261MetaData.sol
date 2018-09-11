pragma solidity ^0.4.24;

import "./ElectusProtocol.sol";
import "./Protocol/IElectusProtocol.sol";


contract ERC1261MetaData is ElectusProtocol, IERC1261Metadata {

    string internal orgName;
    string internal orgSymbol;
    
    constructor() public {
        supportedInterfaces[0x93254542] = true;
    }

    function name() external view returns (string) {
        return orgName;
    }
    
    function symbol() external view returns (string) {
        return orgSymbol;
    }
}