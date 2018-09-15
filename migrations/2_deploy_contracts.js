var ElectusProtocol = artifacts.require("./ElectusProtocol.sol");
var ERC1261MetaData = artifacts.require("./ERC1261MetaData.sol");

//No need to deploy interfaces ...only contracts

module.exports = function(deployer) {
  deployer.deploy(ElectusProtocol);
  deployer.link(ElectusProtocol, ERC1261MetaData);
  deployer.deploy(ERC1261MetaData);
};
