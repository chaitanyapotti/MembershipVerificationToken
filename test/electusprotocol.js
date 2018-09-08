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
