module.exports = {
  norpc: true,
  testCommand: "truffle test --network coverage",
  compileCommand: "truffle compile --network coverage",
  copyPackages: ["openzeppelin-solidity", "ganache-cli"]
};
