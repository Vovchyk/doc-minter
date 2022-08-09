import {HardhatUserConfig, task} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import fs from "fs";

const mnemonic = fs.readFileSync(".secret").toString().trim();

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
    },
    rskTestnet: {
      chainId: 31,
      url: 'https://public-node.testnet.rsk.co/',
      gasMultiplier: 1.1,
      accounts: {
        mnemonic: mnemonic,
        // initialIndex: 0,
        // path: "m/44'/60'/0'/0",
        // count: 10,
      },
    }
  },
  solidity: "0.8.9",
};

task("mint-doc", "Mints DoC tokens")
    .addParam("minterAddr", "DocMinter contract address")
    .addParam("rbtcToMint", "The amount in wei to use for minting DoC tokens")
    .setAction(async (taskArgs, hre) => {
        const docMinterAddr = taskArgs.minterAddr;
        const rbtcToMint = taskArgs.rbtcToMint;

        const accounts = await hre.ethers.getSigners();

        const DocMinter = await hre.ethers.getContractFactory("DocMinter");

        const docMinter =  await DocMinter.attach(docMinterAddr);
        console.log("DocMinter deployed to:", docMinter.address);

        const receiverAddr = await accounts[1].getAddress();
        console.log("receiverAddr:", receiverAddr);

        const refundAddr = await accounts[2].getAddress();
        console.log("refundAddr:", refundAddr);

        const resuot = await docMinter.mintDoc(receiverAddr, refundAddr, {value: rbtcToMint, gasLimit: 1_000_000});
        console.log("Mint result:", resuot);
    });

task("mint-rdoc", "Mints RDoC tokens")
    .addParam("minterAddr", "RDocMinter contract address")
    .addParam("rbtcToMint", "The amount in wei to use for minting RDoC tokens")
    .setAction(async (taskArgs, hre) => {
        const rdocMinterAddr = taskArgs.minterAddr;
        const rbtcToMint = taskArgs.rbtcToMint;

        const accounts = await hre.ethers.getSigners();

        const RDocMinter = await hre.ethers.getContractFactory("RDocMinter");

        const rdocMinter =  await RDocMinter.attach(rdocMinterAddr);
        console.log("RDocMinter deployed to:", rdocMinter.address);

        const receiverAddr = await accounts[1].getAddress();
        console.log("receiverAddr:", receiverAddr);

        const refundAddr = await accounts[2].getAddress();
        console.log("refundAddr:", refundAddr);

        const resuot = await rdocMinter.mintRDoc(receiverAddr, refundAddr, {value: rbtcToMint, gasLimit: 1_000_000});
        console.log("Mint result:", resuot);
    });

export default config;
