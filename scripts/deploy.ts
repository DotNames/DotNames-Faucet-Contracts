const hre = require("hardhat");
require("dotenv").config();
import { ethers, getNamedAccounts } from "hardhat";

async function main() {
  const { deployer, owner } = await getNamedAccounts();

  //DotNames Faucet
  const DotNamesFaucet = await ethers.getContractFactory("DotNamesFaucet");
  const dotNamesFaucet = await DotNamesFaucet.deploy(ethers.utils.parseEther("0.01"));
  await dotNamesFaucet.deployed();
  console.log("DotNamesFaucet address:", dotNamesFaucet.address);
  
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
