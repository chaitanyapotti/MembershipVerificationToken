module.exports = {
  port: 6545,
  testrpcOptions: "-p 6545",
  testCommand:
    "npm run start:blockchain:client & truffle test --network development",
  norpc: true,
  copyPackages: ["openzeppelin-solidity"]
};
