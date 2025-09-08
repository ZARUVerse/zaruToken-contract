const hre = require("hardhat");

async function main() {
  const ZARU = await hre.ethers.getContractFactory("ZARU");
  const zaru = await ZARU.deploy();

  await zaru.deployed();
  console.log("ZARU deployed to:", zaru.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
