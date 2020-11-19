const truffleAssert = require("truffle-assertions");
const ERC1261MetaData = artifacts.require("ERC1261MetaData");
const MembershipVerificationToken = artifacts.require("MembershipVerificationToken");

contract("MembershipVerificationToken", accounts => {
  const trace = false;
  let contractERC1261MetaData = null;
  let contractMembershipVerificationToken = null;
  beforeEach(async () => {
    contractERC1261MetaData = await ERC1261MetaData.new(
      [
        49,
        49,
        234,
        83,
        113,
        55,
        11,
        37,
        223,
        247,
        103,
        251,
        174,
        48,
        198,
        171,
        207,
        47,
        193,
        212,
        116,
        161,
        81,
        28,
        53,
        68,
        148,
        246,
        9,
        90,
        237,
        61
      ],
      [
        219,
        247,
        104,
        65,
        103,
        186,
        227,
        152,
        120,
        160,
        180,
        250,
        27,
        165,
        67,
        218,
        128,
        94,
        75,
        187,
        204,
        234,
        249,
        170,
        169,
        159,
        96,
        52,
        138,
        81,
        37,
        202
      ],
      {from: accounts[0]}
    );
    contractMembershipVerificationToken = await MembershipVerificationToken.new({from: accounts[0]});
  });

  it("Should fail requestMembership(uint[]) when NOT comply with: _attributeIndexes.length == attributeNames.length", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.requestMembership([1338], {from: accounts[0]}), "revert");
  });
  it("Should fail approveRequest(address) when NOT comply with: msg.sender == _owner", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.approveRequest(accounts[5], {from: accounts[9]}), "revert");
  });
  it("Should fail approveRequest(address) when NOT comply with: _user != 0x0000000000000000000000000000000000000000", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.approveRequest("0x0000000000000000000000000000000000000000", {from: accounts[0]}),
      "revert"
    );
  });
  it("Should fail discardRequest(address) when NOT comply with: msg.sender == _owner", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.discardRequest(accounts[1], {from: accounts[9]}), "revert");
  });
  it("Should fail assignTo(address,uint[]) when NOT comply with: msg.sender == _owner", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.assignTo(accounts[2], [], {from: accounts[9]}), "revert");
  });
  it("Should fail assignTo(address,uint[]) when NOT comply with: _to != 0x0000000000000000000000000000000000000000", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.assignTo("0x0000000000000000000000000000000000000000", [], {from: accounts[0]}),
      "revert"
    );
  });
  it("Should fail assignTo(address,uint[]) when NOT comply with: _attributeIndexes.length == attributeNames.length", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.assignTo(accounts[2], [10001], {from: accounts[0]}), "revert");
  });
  it("Should fail revokeFrom(address) when NOT comply with: msg.sender == _owner", async () => {
    const result = await truffleAssert.fails(contractMembershipVerificationToken.revokeFrom(accounts[7], {from: accounts[9]}), "revert");
  });
  it("Should fail revokeFrom(address) when NOT comply with: _from != 0x0000000000000000000000000000000000000000", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.revokeFrom("0x0000000000000000000000000000000000000000", {from: accounts[0]}),
      "revert"
    );
  });
  it("Should fail modifyAttributeByIndex(address,uint,uint) when NOT comply with: msg.sender == _owner", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.modifyAttributeByIndex(accounts[3], 1532892062, 0, {from: accounts[9]}),
      "revert"
    );
  });
  it("Should fail getAttributes(address) when NOT comply with: _to != 0x0000000000000000000000000000000000000000", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.getAttributes("0x0000000000000000000000000000000000000000", {from: accounts[0]}),
      "revert"
    );
  });
  it("Should fail isCurrentMember(address) when NOT comply with: _to != 0x0000000000000000000000000000000000000000", async () => {
    const result = await truffleAssert.fails(
      contractMembershipVerificationToken.isCurrentMember("0x0000000000000000000000000000000000000000", {from: accounts[0]}),
      "revert"
    );
  });
});
