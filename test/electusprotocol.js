var ElectusProtocol = artifacts.require("./ElectusProtocol.sol");

contract("ElectusProtocol", function(accounts) {
  it("he is a current member", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.assignTo(accounts[1], [0], {
      from: accounts[0]
    });
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
  it("list of attributes Names", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.getAttributeNames();
    assert.equal(web3.toAscii(data[1]).replace(/\u0000/g, ""), "skin", 32);
  });
  it("total memebers count", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    member_count = await electusprotocol.totalMemberCount();
    assert.equal(member_count, 1);
  });
  it("list of attributes", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.getAttributes(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace(/\u0000/g, ""), "black", 32);
  });
  it("gets attribute by name", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    data = await electusprotocol.getAttributeByName(accounts[1], "hair");
    assert.equal(web3.toAscii(data).replace(/\u0000/g, ""), "black", 32);
  });
  it("adds a set of attributes", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.addAttributeSet("height", ["5", "6"]);
    data = await electusprotocol.getAttributeNames();
    assert.equal(web3.toAscii(data[2]).replace(/\u0000/g, ""), "height", 32);
  });
  it("modifies attribute by name", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.modifyAttributeByName(accounts[1], "hair", 0);
    data = await electusprotocol.getAttributes(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace(/\u0000/g, ""), "black", 32);
  });
  it("request memebership", async () => {
    const electusprotocol = await ElectusProtocol.deployed();
    await electusprotocol.requestMembership([0], {
      from: accounts[2]
    });
    data = await electusprotocol.getAllMembers();
    attr = await electusprotocol.getAttributes(accounts[2]);
    assert.equal(data[1], accounts[2]);
    assert.equal(web3.toAscii(attr[0]).replace(/\u0000/g, ""), "black", 32);
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
