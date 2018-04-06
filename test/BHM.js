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

contract("BHM", async ([ owner, other, beneficiary1, beneficiary2, ca, ...accounts ]) => {
  let factory, token;

  console.log(owner);
  console.log(other);
  console.log(beneficiary1);
  console.log(beneficiary2);
  console.log(ca);

  const amount = ether(0.0001);

  before(async () => {
    factory = await MiniMeTokenFactory.deployed();
    token = await BHM.new(factory.address);
  });

  // describe("#1 generateTokens", async () => {
  //   it("1-1 only controller should generateTokens", async () => {
  //     const balance1 = await token.balanceOf(beneficiary1);
  //
  //     console.log(balance1);
  //
  //     await token.generateTokens(beneficiary1, amount, { from: owner })
  //       .should.be.fulfilled;
  //     // await token.generateTokens(beneficiary2, amount, { from: owner })
  //     //   .should.be.fulfilled;
  //     const balance2 = await token.balanceOf(beneficiary1);
  //
  //     console.log("beneficiary1: " + balance2);
  //     //console.log("balance1: " + balance1 + " balance2: " + balance2);
  //
  //     assert.equal(balance2 - amount, balance1);
  //     console.log("beneficiary1 balance1: " + balance2);
  //   });
  // });

  // describe("#2 block", async () => {
  //   it("2-1 only controller can block account", async () => {
  //     await token.blockAddress(beneficiary2, {
  //       from: beneficiary1,
  //     }).should.be.rejected;
  //
  //     await token.blockAddress(beneficiary2, {
  //       from: owner,
  //     }).should.be.fulfilled;
  //     console.log("block account success");
  //   });
  //
  //   it("2-2 blocked user should not transfer tokens", async () => {
  //      await token.transfer(beneficiary1, amount, {
  //        from: beneficiary2,
  //      }).should.be.rejected;
  //      console.log("not transfer tokens");
  //   });
  //
  //   it("2-3 only controller can unblock account", async () => {
  //      await token.unblockAddress(beneficiary2, {
  //        from: beneficiary1,
  //      }).should.be.rejected;
  //
  //      await token.unblockAddress(beneficiary2, {
  //        from: owner,
  //      }).should.be.fulfilled;
  //      console.log("block beneficiary2 from owner");
  //   });
  //
  //   // //안되는거 같음 trnasfer
  //   // it("2-4 unblocked user should transfer tokens", async () => {
  //   //
  //   //    await token.unblockAddress(beneficiary2, {
  //   //      from: owner,
  //   //    }).should.be.fulfilled;
  //   //    console.log("Success transfer");
  //   //    await token.transfer(beneficiary1, amount, {
  //   //      from: beneficiary2,
  //   //    }).should.be.rejectedWith("revert");
  //   //    // console.log("test11");
  //   //    // const other1 = await token.balanceOf(beneficiary2);
  //   //    // console.log("other1 :" + other1);
  //   //    // (await token.balanceOf(beneficiary2))
  //   //    //   .assert.equal(0, "transfer success");
  //   //    // (await token.balanceOf(beneficiary1))
  //   //    //   .assert.equal(amount, amount);
  //   //  });
  // });

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
  //      console.log("beneficiary1: " + balance2);
  //   });
  // });

  // describe("#5 Auction", async () => {
  //   it("5-1 creat auction", async () => {
  //     // await token.generateTokens(beneficiary1, ether(0.01), { from: owner })
  //     //         .should.be.fulfilled;
  //     // const balance1 = await token.balanceOf(beneficiary1);
  //     console.log("balance1: " + balance1);
  //     const lowestprice = ether(0.0000000001);
  //     const auctionEndTime = "2222222222";
  //     const agentFee = ether(0.00000000001);
  //     console.log("lowestprice:" + lowestprice + " auctionEndTime:" + auctionEndTime + " agentFee:" + agentFee);
  //     //No events were emitted 안되는거 같음
  //     await token.createAuction(lowestprice, agentFee, auctionEndTime,
  //       {from: beneficiary1, }).should.be.fulfilled;
  //     console.log("create Auction");
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
  //     const deposit = ether(0.0000000001);
  //     const leaseFee = ether(0.00000000005);
  //     const agentFee = ether(0.00000000001);
  //     const uint256[2] paymentTimestamp = ["1829287689","1829287689","1829287689"];
  //
  //     console.log(paymentTimestamp[0]);
  //     console.log(balance1);
  //
  //     // await token.createLease(deposit, leaseFee,
  //     //   false, agentFee, paymentTimestamp[2], { from: beneficiary1 })
  //     //   .should.be.fulfilled;
  //
  //     const balance2 = await token.balanceOf(beneficiary1);
  //
  //     console.log(balance2);
  //
  //     //assert.equal(balance2 - amount, balance1);
  //   });
  //   it("7-2 apply sale", async () => {
  //
  //     await token.applyLease(beneficiary1, "1829287689", { from: other}).should.be.fulfilled;
  //     console.log("apply sale");
  //   });
  //   it("7-3 confrim lease CA", async () => {
  //
  //     await token.confirmLeaseByCA(beneficiary1, "1829287689", { from: owner}).should.be.fulfiled;
  //     console.log("confirm lease CA");
  //   });
  //   it("7-4 withdraw lease fee", async () => {
  //
  //     await token.withdrawLeaseFee("1829287689", { from: other}).should.be.fulfilled;
  //     console.log("withdraw lease fee");
  //   });
  //   it("7-5 withdraw pre deposit lease ", async () => {
  //
  //     await token.withdrawLeaseFee("1829287689", { from: other}).should.be.fulfilled;
  //     console.log("withdraw pre deposit lease");
  //   });
  // });
  describe("#7 Sale", async () => {
    // it("7-1 create sale", async () => {
    //   const balance1 = await token.balanceOf(beneficiary1);
    //   const deposit = ether(0.0000000001);
    //   const agentFee = ether(0.00000000001);
    //   console.log("balance1: " + balance1);
    //   console.log("deposit: " + deposit + "agentFee: " + agentFee);
    //   await token.createSale(deposit, false, agentFee, {from: beneficiary1 }).should.be.fulfilled;
    //   console.log("success create sale");
    //
    // });
    // it("7-2 apply sale", async () => {
    //   const keyTimeStamp = "1429287689";
    //   await token.generateTokens(other, amount, { from: owner })
    //     .should.be.fulfilled;
    //   const balance1 = await token.balanceOf(other);
    //   console.log("balance1 : " + balance1);
    //   await token.applySale(beneficiary1, keyTimeStamp, {from: other }).should.be.fulfilled;
    //   const balance2 = await token.balanceOf(other);
    //   console.log("balance2 : " + balance2);
    //
    // });
    it("7-3 confrim trade CA", async () => {
      // const keyTimeStamp = "1429287689";
      // await token.confirmTradeByCA(beneficiary1, keyTimeStamp, {from: ca}).should.be.fulfilled("revert");
      // console.log("success confirm CA");
      // await token.generateTokens(beneficiary1, amount, { from: owner })
      //   .should.be.fulfilled;
      // await token.generateTokens(other, amount, { from: owner })
      //   .should.be.fulfilled;
      //await token.setDeposit(other, beneficiary1, amount).should.be.fulfiled;
      //await factory.setDeposit(other, beneficiary1, amount).should.be.fulfiled;
    });
  });
});
