const fs = require("fs");
const path = require("path");
const parse = require("csv-parse/lib/sync");

const csvPath = path.resolve(__dirname, "../csv/testTokenHolders.csv");

module.exports = function generateTestTokens(token) {
  const input = fs.readFileSync(csvPath);
  const records = parse(input, { column: true });
  records.splice(0, 1); // remove first line

  const addresses = [];
  const amounts = [];

  for (const [ address, amount ] of records) {
    addresses.push(address);
    amounts.push(amount);

    console.log(`generateTokens(${ address }, ${ amount })`);
  }

  return new Promise((resolve, reject) => {
    token.generateTokensByList(addresses, amounts)
      .then(resolve)
      .catch(reject);
  });
};
