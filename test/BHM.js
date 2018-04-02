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

      assert.equal(balance2 - amount, balance1);
    });
  });

  //  describe("#2 block", async () => {
  //     it("2-1 only controller can block account", async () => {
  //       await token.blockAddress(beneficiary2, {
  //        from: beneficiary1,
  //       }).should.be.rejectedWith(EVMThrow, "revert");
  //
  //       await token.blockAddress(beneficiary2, {
  //         from: owner,
  //       }).should.be.fulfilled;
  //     });
  //
  //   // it("2-2 blocked user should not transfer tokens", async () => {
  //   //    await token.transfer(beneficiary1, amount, {
  //   //      from: beneficiary2,
  //   //    }).assert.throws(EVMThrow, "revert");
  //   // });
  //   //
  //   // it("2-3 only controller can unblock account", async () => {
  //   //    await token.unblockAddress(beneficiary2, {
  //   //      from: beneficiary1,
  //   //    }).should.be.throws(EVMThrow, "revert");
  //   //
  //   //    await token.unblockAddress(beneficiary2, {
  //   //      from: owner,
  //   //    }).assert.ok();
  //   // });
  //   //
  //   // it("2-4 unblocked user should transfer tokens", async () => {
  //   //    await token.transfer(beneficiary1, amount, {
  //   //      from: beneficiary2,
  //   //    }).should.be.fulfilled;
  //   //
  //   //    (await token.balanceOf(beneficiary2))
  //   //      .assert.equal(0, "transfer success");
  //   //    (await token.balanceOf(beneficiary1))
  //   //      .assert.equal(amount, amount);
  //   //  });
  // });

  describe("#3 destroyTokens", async () => {
    it("3-1 only controller should destroyTokens", async () => {
      const balance1 = await token.balanceOf(beneficiary1);

      console.log(balance1);
      //토큰파쾨 0
      await token.destroyTokens(beneficiary1, amount, { from: owner }).should.be.fulfilled;

      const balance2 = await token.balanceOf(beneficiary1);
      console.log(balance2);
      //잔고 0 확인
      assert.equal(0, balance2);
    });
  });

  describe("#4 deposit", async () => {
    // it("4-1 setDeposit", async () => {
    //   const balance1 = await token.balanceOf(beneficiary1);
    //   console.log(balance1);
    //   await token.generateTokens(beneficiary1, amount, { from: owner }).should.be.fulfilled;
    //   const balance2 = await token.balanceOF(beneficiary1);
    //   await token.setDeposit(beneficiary1, owner, amount).should.be.fulfilled;
    //   const balance3 = await token.balanceOF(beneficiary1);
    // });
    // it("4-2 updateDepositValueAtNow", async () => {
    //    await token.updateDepositValueAtNow(checkpoints, depositValue, claimerDepositValue, to {
    //
    //    }).should.be.fulfilled;
    //  });
    // it("4-3 depositBalanceOfAt", async () => {
    //   await token.depositBalanceOfAt(owner, blockNumber {
    //
    //   }).should.be.fulfilled;
    // });
    // it("4-4 getDepositValueAt", async () => {
    //   await token.getDepositValueAt(checkpoints, block {
    //
    //   }).should.be.fulfiled
    // });
    // it("4-5 claimerBalanceAt", async () => {
    //   await token.claimerBalanceAt(owner, blockNumber, to{
    //
    //   }).should.be.fulfiled
    // });
    // it("4-6 getClaimerValueAt", async () => {
    //   await token.getClaimerValueAt(checkpoints, block, to{
    //
    //   }).should.be.fulfiled
    // });
    // it("4-7 withdrawDeposit", async () => {
    //    await token.withdrawDeposit (from, to, amount {
    //
    //    }).should.be.fulfiled
    //  });
  });

  // describe("#5 Auction", async () => {
  //   it("5-1 creat auction", async () => {
  //     const balance1 = await token.balanceOf(msg.sender);
  //     console.log(balance1);
  //     await token.generateTokens(msg.sender, amount, { from: owner })
  //       .should.be.fulfilled;
  //
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime {
  //     }).should.be.fulfilled;
  //     const balcance2 = await token.balance
  //     console.log(balance2);
  //     assert.equal(balance2 - amount, balance1);
  //   });
  //   it("5-2 Bid auction", async () => {
  //     const balance = await token.balanceOf(beneficiary);
  //     console.log(balance);
  //
  //     await token.generateTokens(beneficiary1, amount, { from: owner })
  //       .should.be.fulfilled;
  //
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime{
  //
  //     });
  //
  //     console.log(balance2);
  //     assert.equal(balance2 - amount, balance1);
  //   });
  //   it("5-3 creat auction", async () => {
  //     const balance = await token.balanceOf(beneficiary);
  //     console.log(balance);
  //
  //     await token.generateTokens(beneficiary1, amount, { from: owner })
  //       .should.be.fulfilled;
  //
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime{
  //
  //     });
  //
  //     console.log(balance2);
  //     assert.equal(balance2 - amount, balance1);
  //   });
  //   it("5-4 creat auction", async () => {
  //     const balance = await token.balanceOf(beneficiary);
  //     console.log(balance);
  //
  //     await token.generateTokens(beneficiary1, amount, { from: owner })
  //       .should.be.fulfilled;
  //
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime{
  //
  //     });
  //
  //     console.log(balance2);
  //     assert.equal(balance2 - amount, balance1);
  //   });
  // });
});
