module.exports = {
  testrpcOptions: `--port 8555 -i 1999 --noVMErrorsOnRPCResponse`,
  testCommand: "node --max-old-space-size=4096 truffle test --network coverage",
  compileCommand: "truffle compile",
  copyPackages: ["openzeppelin-solidity", "ganache-cli"]
};
