import { ethers } from "hardhat";

// RSK Testnet addresses of MoC contracts
const mocAddr = "0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F";
const docAddr = "0xCB46c0ddc60D18eFEB0E586C17Af6ea36452Dae0";
const mocExchangeAddr = "0xc03Ac60eBbc01A1f4e9b5bb989F359e5D8348919";
const mocInrateAddr = "0x76790f846FAAf44cf1B2D717d0A6c5f6f5152B60";
const mocVendorsAddr = "0xbB3552267f52B0F06BefBD1bd587E3dBFc7d06BD";

async function main() {
  const DocMinter = await ethers.getContractFactory("DocMinter");
  const docMinter = await DocMinter.deploy(mocAddr, docAddr, mocExchangeAddr, mocInrateAddr, mocVendorsAddr);

  await docMinter.deployed();

  console.log("DocMinter deployed to:", docMinter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
