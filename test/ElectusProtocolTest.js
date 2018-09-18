var ElectusProtocol = artifacts.require("./ElectusProtocol.sol");

contract("ElectusProtocol", function(accounts) {
  let electusProtocol;
  beforeEach("setup", async () => {
    electusProtocol = await ElectusProtocol.new();
    await electusProtocol.addAttributeSet("0x68616972", ["0x626c61636b", "0x7768697465"]);
    await electusProtocol.addAttributeSet("0x736b696e", ["0x626c61636b", "0x7768697465"]);
    await electusProtocol.assignTo(accounts[1], [0], {
      from: accounts[0]
    });
  });
  it("he is a current member", async () => {
    const data = await electusProtocol.isCurrentMember(accounts[1]);
    assert.equal(data, true);
  });
  it("he is not a current member", async () => {
    const data = await electusProtocol.isCurrentMember(accounts[2]);
    assert.equal(data, false);
  });
  it("gets all memebers", async () => {
    const data = await electusProtocol.getAllMembers();
    assert.equal(data[0], accounts[1]);
  });
  it("list of attributes Names", async () => {
    const data = await electusProtocol.getAttributeNames();
    assert.equal(web3.toAscii(data[1]).replace("/\u0000/g", ""), "skin", 32);
  });
  it("list of attributes of a member", async () => {
    const data = await electusProtocol.getAttributes(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace("/\u0000/g", ""), "black", 32);
  });
  it("gets attribute of a member by name", async () => {
    const data = await electusProtocol.getAttributeByName(accounts[1], "hair");
    assert.equal(web3.toAscii(data).replace("/\u0000/g", ""), "black", 32);
  });
  it("adds a set of attributes", async () => {
    await electusProtocol.addAttributeSet("height", ["5", "6"]);
    const data = await electusProtocol.getAttributeNames();
    assert.equal(web3.toAscii(data[2]).replace("/\u0000/g", ""), "height", 32);
  });
  it("modifies attribute by name", async () => {
    await electusProtocol.modifyAttributeByName(accounts[1], "hair", 0);
    const data = await electusProtocol.getAttributes(accounts[1]);
    assert.equal(web3.toAscii(data[0]).replace("/\u0000/g", ""), "black", 32);
  });
  it("request memebership", async () => {
    await electusProtocol.requestMembership([0], {
      from: accounts[2]
    });
    const data = await electusProtocol.getAllMembers();
    const attr = await electusProtocol.getAttributes(accounts[2]);
    assert.equal(data[1], accounts[2]);
    assert.equal(web3.toAscii(attr[0]).replace("/\u0000/g", ""), "black", 32);
  });
  it("self revoke memebership", async () => {
    await electusProtocol.forfeitMembership({
      from: accounts[1]
    });
    const data = await electusProtocol.isCurrentMember(accounts[1]);
    assert.equal(data, false);
  });
  it("owner revokes memebership", async () => {
    await electusProtocol.revokeFrom(accounts[1], {
      from: accounts[0]
    });
    const data = await electusProtocol.isCurrentMember(accounts[1]);
    assert.equal(data, false);
  });
});
