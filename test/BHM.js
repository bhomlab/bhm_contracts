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
      // await token.generateTokens(beneficiary2, amount, { from: owner })
      //   .should.be.fulfilled;
      const balance2 = await token.balanceOf(beneficiary1);

      console.log("beneficiary1: " + balance2);
      //console.log("balance1: " + balance1 + " balance2: " + balance2);

      assert.equal(balance2 - amount, balance1);
    });
  });

  describe("#2 block", async () => {
    it("2-1 only controller can block account", async () => {
      await token.blockAddress(beneficiary2, {
        from: beneficiary1,
      }).should.be.rejected;

      await token.blockAddress(beneficiary2, {
        from: owner,
      }).should.be.fulfilled;
    });

    it("2-2 blocked user should not transfer tokens", async () => {
       await token.transfer(beneficiary1, amount, {
         from: beneficiary2,
       }).should.be.rejected;
    });

    it("2-3 only controller can unblock account", async () => {
       await token.unblockAddress(beneficiary2, {
         from: beneficiary1,
       }).should.be.rejected;

       await token.unblockAddress(beneficiary2, {
         from: owner,
       }).should.be.fulfilled;
    });

    // 안되는거 같음 trnasfer
    // it("2-4 unblocked user should transfer tokens", async () => {
    //    // await token.generateTokens(beneficiary2, amount, { from: owner })
    //    //  .should.be.fulfilled;
    //    await token.unblockAddress(beneficiary2, {
    //      from: owner,
    //    }).should.be.fulfilled;
    //    console.log("test");
    //    await token.transfer(beneficiary1, amount, {
    //      from: beneficiary2,
    //    }).should.be.fulfilled;
    //    // console.log("test11");
    //    // const other1 = await token.balanceOf(beneficiary2);
    //    // console.log("other1 :" + other1);
    //    // (await token.balanceOf(beneficiary2))
    //    //   .assert.equal(0, "transfer success");
    //    // (await token.balanceOf(beneficiary1))
    //    //   .assert.equal(amount, amount);
    //  });
  });

  // describe("#3 destroyTokens", async () => {
  //    it("3-1 only controller should destroyTokens", async () => {
  //      const balance1 = await token.balanceOf(beneficiary1);
  //
  //      console.log("beneficiary1: " + balance1);
  //      //토큰파쾨 0
  //      await token.destroyTokens(beneficiary1, amount, { from: owner, }).should.be.fulfilled;
  //
  //      const balance2 = await token.balanceOf(beneficiary1);
  //      console.log("beneficiary1: " + balance2);
  //      //일치 확인
  //      assert.equal(balance2, 0);
  //   });
  // });

  // describe("#4 deposit", async () => {
  //   it("4-1 setDeposit", async () => {
  //     const balance1 = await token.balanceOf(beneficiary1);
  //     console.log(balance1);
  //     // await token.generateTokens(beneficiary1, amount, { from: owner }).should.be.fulfilled;
  //     // const balance2 = await token.balanceOF(beneficiary1);
  //     await factory.setDeposit(owner, amount, { from: beneficiary1}).should.be.fulfilled;
  //     const balance2 = await token.balanceOF(beneficiary1);
  //     assert.equal(balance1 - amount, balance2);
  //   });
  //   it("4-2 updateDepositValueAtNow", async () => {
  //      await token.updateDepositValueAtNow(checkpoints, depositValue, claimerDepositValue, to {
  //
  //      }).should.be.fulfilled;
  //    });
  //   it("4-3 depositBalanceOfAt", async () => {
  //     await token.depositBalanceOfAt(owner, blockNumber {
  //
  //     }).should.be.fulfilled;
  //   });
  //   it("4-4 getDepositValueAt", async () => {
  //     await token.getDepositValueAt(checkpoints, block {
  //
  //     }).should.be.fulfiled
  //   });
  //   it("4-5 claimerBalanceAt", async () => {
  //     await token.claimerBalanceAt(owner, blockNumber, to{
  //
  //     }).should.be.fulfiled
  //   });
  //   it("4-6 getClaimerValueAt", async () => {
  //     await token.getClaimerValueAt(checkpoints, block, to{
  //
  //     }).should.be.fulfiled
  //   });
  //   it("4-7 withdrawDeposit", async () => {
  //      const balance1 =  await token.balanceOf(beneficiary1);
  //      console.log(balance1);
  //
  //      await factory.withdrawDeposit (, to, amount {}).should.be.fulfiled
  //    });
  // });

  // describe("#5 Auction", async () => {
  //   it("5-1 creat auction", async () => {
  //     const balance1 = await token.balanceOf(beneficiary1);
  //     console.log(balance1);
  //     // await token.generateTokens(beneficiary1, amount, { from: owner })
  //     //   .should.be.fulfilled;
  //
  //     const lowestprice = ether(0.00001);
  //     const auctionEndTime = 1829287689;
  //     const agentFee = ether(0.000001);
  //     console.log("lowestprice:" + lowestprice + " auctionEndTime:" + auctionEndTime + " agentFee:" + agentFee);
  //     // await token.generateTokens(msg.sender, amount, { from: owner })
  //     //   .should.be.fulfilled;
  //     //No events were emitted
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime,
  //       {from: beneficiary1, }).should.be.fulfilled;
  //     //assert.notequal(auctionEndTime, NOW);
  //   });
  //   // it("5-2 Bid auction", async () => {
  //   //   const balance1 = await token.balanceOf(other);
  //   //   console.log(other);
  //   //
  //   //   await token.bidAuction(bid, {
  //   //   keyTimeStamp: web3.timestamp,
  //   //   from: other,
  //   //   bid:2}).should.be.fulfilled;
  //   //
  //   //   const balance2 = await token.balanceOf(other);
  //   //   console.log(balance2);
  //   //   assert.equal(balance1 - bid, balance2);
  //   // });
  //   // it("5-3 escro auction", async () => {
  //   //   const balance1 = await token.balanceOf(other);
  //   //   console.log(balance1);
  //   //   await token.escroAuction({
  //   //     agentFee: 1,
  //   //     from: other,
  //   //   }).should.be.fulfilled;
  //   //   const balance2 = await token.balancOf(other);
  //   //   console.log(balance2);
  //   //   assert.equal(balance);
  //   // });
  //   // it("5-3 withDraw auction", async () => {
  //   //   const balance1 = await token.balanceOf(beneficiary1);
  //   //   const balance2 = await token.balanceOf(other);
  //   //   console.log(balance1);
  //   //   console.log(balance2);
  //   //   await token.escroAuction(beneficiary1, amount).should.be.fulfilled;
  //   //
  //   // });
  // });
  // describe("#6 lease", async () => {
  //   it("7-1 create lease", async () => {
  //     const balance1 = await token.balanceOf(beneficiary1);
  //
  //     console.log(balance1);
  //
  //     await token.createlease(deposit, leaseFee,
  //       useCA, agentFee, paymentTimestamp, { from: beneficiary1 })
  //       .should.be.fulfilled;
  //
  //     const balance2 = await token.balanceOf(beneficiary1);
  //
  //     console.log(balance2);
  //
  //     //assert.equal(balance2 - amount, balance1);
  //   });
  //   it("7-2 apply sale", async () => {
  //
  //   });
  //   it("7-3 confrim lease CA", async () => {
  //
  //   });
  //   it("7-4 withdraw lease fee", async () => {
  //
  //   });
  //   it("7-5 withdraw pre deposit lease ", async () => {
  //
  //   });
  // });
  describe("#7 Sale", async () => {
    console.log("test");
    it("7-1 create sale", async () => {
      const balance1 = await token.balanceOf(beneficiary1);
      const deposit = ether(0.0000000001);
      const agentFee = ether(0.00000000001);
      console.log("balance1: " + balance1);

      await token.createSale(deposit, false, agentFee, {from: beneficiary1 }).should.be.rejected;
      console.log(now);
    });
    it("7-2 apply sale", async () => {
      const keyTimeStamp = now;
      await token.applySale(beneficiary1, keyTimeStamp, {from: other }).should.be.fulfilled;
    });
    it("7-3 confrim trade CA", async () => {
      await token.confirmTradeByCA(beneficiary, keyTimeStamp, {from: other}).should.be.fulfilled;
    });
  });
});
