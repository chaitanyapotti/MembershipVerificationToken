var ElectusProtocol = artifacts.require("./ElectusProtocol.sol");

contract("ElectusProtocol", function(accounts) {
  it("get data for a current member", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.assignTo(accounts[1], ["orange"], {
      from: accounts[0]
    });
    data = await electusprotocol.getData.call(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace(/\u0000/g, ""), "orange", 32);
  });
  it("he is a current member", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.isCurrentMember(accounts[1]);
    assert.equal(data, true);
  });
  it("he is not a current member", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.isCurrentMember(accounts[2]);
    assert.equal(data, false);
  });
  it("gets all memebers", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.getAllMembers();
    assert.equal(data[0], accounts[1]);
  });
  it("total memebers count", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    member_count = await electusprotocol.totalMemberCount();
    assert.equal(member_count, 1);
  });
  it("modifies data", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.modifyData(accounts[1], ["banana"], {
      from: accounts[0]
    });
    data = await electusprotocol.getData.call(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace(/\u0000/g, ""), "banana", 32);
  });
  it("request memebership", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.requestMembership(["grape"], {
      from: accounts[2]
    });
    data = await electusprotocol.getAllMembers();
    assert.equal(data[1], accounts[2]);
  });
  it("self revoke memebership", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.revokeMembership({
      from: accounts[2]
    });
    data = await electusprotocol.isCurrentMember(accounts[2]);
    assert.equal(data, false);
  });
  it("owner revokes memebership", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.revokeFrom(accounts[1], {
      from: accounts[0]
    });
    data = await electusprotocol.isCurrentMember(accounts[1]);
    assert.equal(data, false);
  });
});

// var MetaCoin = artifacts.require("./MetaCoin.sol");

// contract('MetaCoin', function(accounts) {
//   it("should put 10000 MetaCoin in the first account", function() {
//     return MetaCoin.deployed().then(function(instance) {
//       return instance.getBalance.call(accounts[0]);
//     }).then(function(balance) {
//       assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
//     });
//   });
//   it("should call a function that depends on a linked library", function() {
//     var meta;
//     var metaCoinBalance;
//     var metaCoinEthBalance;

//     return MetaCoin.deployed().then(function(instance) {
//       meta = instance;
//       return meta.getBalance.call(accounts[0]);
//     }).then(function(outCoinBalance) {
//       metaCoinBalance = outCoinBalance.toNumber();
//       return meta.getBalanceInEth.call(accounts[0]);
//     }).then(function(outCoinBalanceEth) {
//       metaCoinEthBalance = outCoinBalanceEth.toNumber();
//     }).then(function() {
//       assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpected function, linkage may be broken");
//     });
//   });
//   it("should send coin correctly", function() {
//     var meta;

//     // Get initial balances of first and second account.
//     var account_one = accounts[0];
//     var account_two = accounts[1];

//     var account_one_starting_balance;
//     var account_two_starting_balance;
//     var account_one_ending_balance;
//     var account_two_ending_balance;

//     var amount = 10;

//     return MetaCoin.deployed().then(function(instance) {
//       meta = instance;
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_starting_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_starting_balance = balance.toNumber();
//       return meta.sendCoin(account_two, amount, {from: account_one});
//     }).then(function() {
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_ending_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_ending_balance = balance.toNumber();

//       assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
//       assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
//     });
//   });
// });
