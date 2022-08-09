import { ethers } from "hardhat";

// RSK Testnet addresses of Rif On Chain contracts
const rskSwapAddr = "0xf55c496bb1058690db1401c4b9c19f3f44374961";
const rifAddr = "0x19f64674d8a5b4e652319f5e239efd3bc969a1fe";
const mocAddr = "0x7e2F245F7dc8e78576ECB13AEFc0a101E9BE1AD3";
const docAddr = "0xC3De9F38581f83e281f260d0DdbaAc0e102ff9F8";
const mocExchangeAddr = "0x7d5804E33B015b43159e61188526C93cfdA746f6";
const mocInrateAddr = "0x4C54053845F4f219AddB43ef3A7d4478E89a2A47";
const mocVendorsAddr = "0x60E38CB11562C665A6efac87406B7B0bDE725576";

async function main() {
  const RDocMinter = await ethers.getContractFactory("RDocMinter");
  const rdocMinter = await RDocMinter.deploy(rskSwapAddr, rifAddr, mocAddr, docAddr, mocExchangeAddr, mocInrateAddr, mocVendorsAddr);

  await rdocMinter.deployed();

  console.log("RDocMinter deployed to:", rdocMinter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
