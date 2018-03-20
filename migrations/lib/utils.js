const moment = require("moment");
const BigNumber = require("bignumber.js");
const Web3 = require("web3");
const HDWalletProvider = require("truffle-hdwallet-provider");

const secToMillisec = sec => sec * 1000;

exports.ether = n => new BigNumber(n).mul(1e18);

exports.timeout = ms => new Promise(resolve => setTimeout(resolve, ms));

exports.waitUntil = async (targetTime) => {
  const now = moment().unix();
  await exports.timeout(secToMillisec(targetTime - now));
};

exports.stringify = obj => JSON.stringify(obj, undefined, 2);

exports.receiptHandler = async (PromiEvent, expectToThrow = false, hashOnly = false) => {
  try {
    const r = await PromiEvent;
    console.log(r);
  } catch (e) {
    console.error(e.message);
    PromiEvent.once("transactionHash", console.log)
      .once("receipt", console.log);
  }
};

exports.sliceAccount = (accounts, start = 0, n = 4) => (_n = n) => {
  const r = accounts.slice(start, start + _n);
  start += _n;
  return r;
};

exports.loadWeb3FromMnemonic = (providerUrl, mnemonic) => {
  const web3 = new Web3();
  const provider = new HDWalletProvider(mnemonic, providerUrl, 0, 50);
  web3.setProvider(provider);

  const owner = provider.addresses[ 0 ];
  return { web3, owner };
};

exports.loadWeb3FromPK = (providerUrl, privKey) => {
  const web3 = new Web3();
  web3.setProvider(providerUrl);

  const account = web3.eth.accounts.privateKeyToAccount(privKey);
  web3.eth.accounts.wallet.add(account);

  const owner = account.address;

  return { web3, owner };
};

function loadContract(Contract, { address = null, networkId = null }) {
  if (address && networkId) throw new Error("Use one of address or networkId of network. Not both of them");

  if (networkId) {
    address = Contract.networks[ networkId ].address;
  }

  return {
    abi: Contract.abi,
    address,
  };
}
