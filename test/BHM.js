const ether = require("./library/ether");
const EVMThrow = require("./library/EVMThrow");
const assert = require('assert');

const BigNumber = web3.BigNumber;
BigNumber.prototype.diff = function diff(n, r, e = new BigNumber(1e-10)) {
  n = new BigNumber(n);
  r = new BigNumber(r);
  e = new BigNumber(e);

  const _s = r.sub(e);
  const _n = this.sub(n).abs();
  const _e = r.add(e);

  return _n.gt(_s) && _n.lt(_e);
};

const eth = web3.eth;

const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const MiniMeTokenFactory = artifacts.require("./MiniMeTokenFactory.sol");
const BHM = artifacts.require("BHM.sol");

contract("BHM", async ([ owner, other, beneficiary1, beneficiary2, ...accounts ]) => {
  let factory, token;

  console.log(owner);
  console.log(other);
  console.log(beneficiary1);
  console.log(beneficiary2);

  const amount = ether(0.0001);

  before(async () => {
    factory = await MiniMeTokenFactory.deployed();
    token = await BHM.new(factory.address);
  });

  describe("#1 generateTokens", async () => {
    it("1-1 only controller should generateTokens", async () => {
      const balance1 = await token.balanceOf(beneficiary1);

      console.log(balance1);

      await token.generateTokens(beneficiary1, amount, { from: owner })
        .should.be.fulfilled;

      const balance2 = await token.balanceOf(beneficiary1);

      console.log(balance2);

      should.equal(balance2 - amount, balance1);
    });
  });

  describe("#2 block", async () => {
  //   it("2-1 only controller can block account", async () => {
  //     await token.blockAddress(beneficiary2, {
  //       from: beneficiary1,
  //     }).should.be.rejectedWith(EVMThrow, "revert");
  //
  //     await token.blockAddress(beneficiary2, {
  //       from: owner,
  //     }).should.be.fulfilled;
  //   });

    // it("2-2 blocked user should not transfer tokens", async () => {
    //    await token.transfer(beneficiary1, amount, {
    //      from: beneficiary2,
    //    }).assert.throws(EVMThrow, "revert");
    // });
    //
    // it("2-3 only controller can unblock account", async () => {
    //    await token.unblockAddress(beneficiary2, {
    //      from: beneficiary1,
    //    }).should.be.throws(EVMThrow, "revert");
    //
    //    await token.unblockAddress(beneficiary2, {
    //      from: owner,
    //    }).assert.ok();
    // });
    //
    // it("2-4 unblocked user should transfer tokens", async () => {
    //    await token.transfer(beneficiary1, amount, {
    //      from: beneficiary2,
    //    }).should.be.fulfilled;
    //
    //    (await token.balanceOf(beneficiary2))
    //      .assert.equal(0, "transfer success");
    //    (await token.balanceOf(beneficiary1))
    //      .assert.equal(amount, amount);
    //  });
  });


});
