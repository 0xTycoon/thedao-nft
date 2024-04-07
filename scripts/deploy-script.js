// npx hardhat run scripts/deploy-script.js --network localhost
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Redeemer = await hre.ethers.getContractFactory("Redeemer");
  const v3 = await Redeemer.deploy(
      "0x266830230bf10A58cA64B7347499FD361a011a02", // v1
      "0x79a7D3559D73EA032120A69E59223d4375DEb595", // v2
      "0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413", // thedao
      "0xCB56b52316041A62B6b5D0583DcE4A8AE7a3C629" // cig
      );

  await v3.deployed();

  console.log("Redeemer deployed to:", v3.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
