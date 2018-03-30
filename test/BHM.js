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

  
 
    
});