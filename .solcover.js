module.exports = {
  testrpcOptions: `--port 8555 -i 1999 --noVMErrorsOnRPCResponse`,
  testCommand: "truffle test --network coverage",
  compileCommand: "../node_modules/.bin/truffle compile",
  copyPackages: ["openzeppelin-solidity"]
};
