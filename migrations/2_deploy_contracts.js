const moment = require("moment");
const { sprintf } = require("sprintf-js");



const { ether } = require("./lib/utils");

const MiniMeTokenFactory = artifacts.require("./MiniMeTokenFactory.sol");
const BHM = artifacts.require("./BHM.sol");

const BigNumber = web3.BigNumber;
const addressFormat = "%35s\t%50s";

const queue = [];
const clearQueue = async () => {
  let p;
  while (p = queue.pop()) {
    await p;
  }
  return true;
};

const logAccount = (account, i) => console.log(`[${ i }] ${ account }`);

module.exports = async function (deployer, network, accounts) {
  accounts.map(logAccount);

  try {
    // parameters
//    let params;
//
//    if (network === "mainnet") {
//      params = setParams.mainnet(accounts);
//    } else if (network === "ropsten") {
//      params = setParams.ropsten(accounts);
//    } else if (network === "ropsten.test"
//      || network === "mainnet.test") {
//      params = setParams.publicnet(accounts, ether(0.04));
//    } else if (network === "public.mock") {
//      params = setParams[ "public.mock" ](accounts, ether(0.04));
//    } else {
//      params = setParams.development(accounts);
//    }



    // contracts
    let factory;
    let token;

    // TODO: next truffle version should enable `await deployer.deploy()`
    // deploy basic contracts
    deployer.deploy([
      MiniMeTokenFactory
      ]).then(async () => {
      // load contract instances
      factory = await MiniMeTokenFactory.deployed();
      
      // deploy token
      return deployer.deploy(BHM, factory.address);
    }).then(async () => {
      token = await BHM.deployed();
    });
  } catch (e) {
    console.error(e);
  }
};
