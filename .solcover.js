module.exports = {
  norpc: true,
  testCommand: "node --max-old-space-size=4096 truffle test --network coverage",
  compileCommand: "truffle compile --network coverage",
  copyPackages: ["openzeppelin-solidity", "ganache-cli"]
};
