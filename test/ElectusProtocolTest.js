var ElectusProtocol = artifacts.require("./MembershipVerificationToken.sol");
const truffleAssert = require("truffle-assertions");

contract("ElectusProtocol", function(accounts) {
  let electusProtocol;
  beforeEach("setup", async () => {
    electusProtocol = await ElectusProtocol.new();
    await electusProtocol.addAttributeSet("0x68616972", ["0x626c61636b", "0x7768697465"]);
    await electusProtocol.addAttributeSet("0x736b696e", ["0x626c61636b", "0x7768697465"]);
    await electusProtocol.assignTo(accounts[1], [0, 0], { from: accounts[0] });
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
  it("gets current memeber count", async () => {
    await electusProtocol.assignTo(accounts[2], [0, 0], { from: accounts[0] });
    await electusProtocol.revokeFrom(accounts[1], { from: accounts[0] });
    const data = await electusProtocol.getCurrentMemberCount();
    assert.equal(data, 1);
  });
  it("list of attributes Names", async () => {
    const data = await electusProtocol.getAttributeNames();
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(data[1]).replace(/\u0000/g, ""), "skin", 32);
  });
  it("list of attributes of a member", async () => {
    const data = await electusProtocol.getAttributes(accounts[1]);
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(data[0]).replace(/\u0000/g, ""), "black", 32);
  });
  it("gets attribute of a member by name", async () => {
    const data = await electusProtocol.getAttributeByName(accounts[1], web3.utils.fromAscii("hair"));
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(data).replace(/\u0000/g, ""), "black", 32);
  });
  it("adds a set of attributes", async () => {
    await electusProtocol.addAttributeSet(web3.utils.fromAscii("height"), [web3.utils.fromAscii("5"), web3.utils.fromAscii("6")]);
    const data = await electusProtocol.getAttributeNames();
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(data[2]).replace(/\u0000/g, ""), "height", 32);
  });
  it("modifies attribute by name", async () => {
    const result = await electusProtocol.modifyAttributeByName(accounts[1], web3.utils.fromAscii("hair"), 0);
    const data = await electusProtocol.getAttributes(accounts[1]);
    truffleAssert.eventEmitted(result, "ModifiedAttributes");
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(data[0]).replace(/\u0000/g, ""), "black", 32);
  });
  it("request memebership", async () => {
    const requestedMembership = await electusProtocol.requestMembership([0, 0], {
      from: accounts[2]
    });
    const data = await electusProtocol.isCurrentMember(accounts[2]);
    const isMembershipPending = await electusProtocol.pendingRequests(accounts[2]);
    assert.equal(isMembershipPending, true);
    assert.equal(data, false);
    truffleAssert.eventEmitted(requestedMembership, "RequestedMembership");
  });
  it("request and approve memebership", async () => {
    const requestedMembership = await electusProtocol.requestMembership([0, 0], {
      from: accounts[2]
    });
    const approvedMembership = await electusProtocol.approveRequest(accounts[2], {
      from: accounts[0]
    });
    const data = await electusProtocol.isCurrentMember(accounts[2]);
    assert.equal(data, true);
    const attr = await electusProtocol.getAttributes(accounts[2]);
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.utils.toAscii(attr[0]).replace(/\u0000/g, ""), "black", 32);
    truffleAssert.eventEmitted(requestedMembership, "RequestedMembership");
    truffleAssert.eventEmitted(approvedMembership, "ApprovedMembership");
  });
  it("discard memebership request", async () => {
    const requestedMembership = await electusProtocol.requestMembership([0, 0], {
      from: accounts[2]
    });
    await electusProtocol.discardRequest(accounts[2], {
      from: accounts[0]
    });
    const isMembershipPending = await electusProtocol.pendingRequests(accounts[2]);
    const data = await electusProtocol.isCurrentMember(accounts[2]);
    assert.equal(isMembershipPending, false);
    assert.equal(data, false);
    truffleAssert.eventEmitted(requestedMembership, "RequestedMembership");
  });
  it("self revoke memebership", async () => {
    const revoke = await electusProtocol.forfeitMembership({
      from: accounts[1]
    });
    truffleAssert.eventEmitted(revoke, "Revoked");
    const data = await electusProtocol.isCurrentMember(accounts[1]);
    assert.equal(data, false);
  });
  it("owner revokes memebership", async () => {
    const revoke = await electusProtocol.revokeFrom(accounts[1], {
      from: accounts[0]
    });
    truffleAssert.eventEmitted(revoke, "Revoked");
    const data = await electusProtocol.isCurrentMember(accounts[1]);
    assert.equal(data, false);
  });
  it("gets attribute collection", async () => {
    const data = await electusProtocol.getAttributeExhaustiveCollection("0x68616972");
    assert.equal("0" + data[0].replace(/0/g, ""), "0x626c61636b");
  });
});
