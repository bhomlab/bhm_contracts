const Web3 = require("web3"); 
const HDWalletProvider = require("truffle-hdwallet-provider");
require("dotenv").config();

const web3 = new Web3();
const providerUrl = "https://mainnet.infura.io"; //TODO change mainnet
const bhmAddress = ""; // TODO replace with real BHM address
const adminAddress = process.argv[ 2 ];
const mnemonic = process.env.MNEMONIC || "";//TODO

const provider = new HDWalletProvider(mnemonic, providerUrl, 0, 50);
web3.setProvider(provider);
 
 
const seedOwner = provider.addresses[ 0 ];

const encodedKycSignature = web3.eth.abi.encodeFunctionSignature({
    name: 'setAdmin',
    type: 'function',
    inputs: [{
        type: 'address',
        name: '_addr',
    },
    {
        type: 'bool',
        name: '_value',
    }]
});

async function mnemonicMain() {
//	console.log(encodedKycSignature);
  setAdmin(seedOwner, bhmAddress, adminAddress)
    .then(JSON.stringify)
    .then(console.log)
    .catch(console.error);
}

mnemonicMain();

function setAdmin(_seedOwner, _bhmAddress, _addr, _value) {
  return web3.eth.sendTransaction({
    from: _seedOwner,
    to: _bhmAddress,
    data: makeDataField(_addr, _value),
    gas: 1000000,
    gasPrice: 25e9,
  });
}

function removePrefix(hex) {
  if (typeof hex === "number") hex = web3.utils.fromDecimal(hex);
  if (hex.slice(0, 2) === "0x") return hex.slice(2);
  return hex;
}

function addPrefix(hex) {
  if (typeof hex === "number") hex = web3.utils.fromDecimal(hex);
  if (hex.slice(0, 2) === "0x") return hex;
  return `0x${ hex }`;
}

function leftPad(hex, len = 64, prefix = false) {
  hex = web3.utils.toHex(hex);
  const r = removePrefix(hex).padStart(len, "0");
  const f = prefix ? addPrefix : removePrefix;
  return f(r);
}

function makeDataField(_addr, _value) {
  return [
	encodedKycSignature,
    leftPad(_addr),
    leftPad(_value),
  ].join("");
}