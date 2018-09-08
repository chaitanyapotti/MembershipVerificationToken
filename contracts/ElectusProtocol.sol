pragma solidity ^0.4.24;

import "zeppelin/contracts/ownership/Ownable.sol";
import "./Protocol/IElectusProtocol.sol";


contract ElectusProtocol is ERC1261, ERC173, ERC165 {
    
    
    event Assigned(address indexed to);
    event Revoked(address indexed to);
}