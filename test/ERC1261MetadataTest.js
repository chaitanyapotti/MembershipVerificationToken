var ERC1261Metadata = artifacts.require("./ERC1261MetaData.sol");

contract("metadata test", function(accounts) {
  let metadata;
  beforeEach("setup", async () => {
    metadata = await ERC1261Metadata.new("0x57616e636861696e", "0x57414e");
  });
  it("gets name of the organisation", async () => {
    const name = await metadata.name();
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.toAscii(name).replace(/\u0000/g, ""), "Wanchain", 32);
  });
  it("gets symbol of the organisation", async () => {
    const symbol = await metadata.symbol();
    // eslint-disable-next-line no-control-regex
    assert.equal(web3.toAscii(symbol).replace(/\u0000/g, ""), "WAN", 32);
  });
});
