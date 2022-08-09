# Sample DoC Minter Project

This project demonstrates a basic DoC token minting use case. It comes with a sample contract, a test for that contract,
a script that deploys that contract, and a task that mints DoC tokens.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy-doc-minter.ts
npx hardhat run scripts/deploy-doc-minter.ts --network rskTestnet
npx hardhat run scripts/deploy-rdoc-minter.ts
npx hardhat run scripts/deploy-rdoc-minter.ts --network rskTestnet
npx hardhat mint-doc --minter-addr "<minter addr>" --rbtc-to-mint "<rbtc to mint>" --network rskTestnet
npx hardhat mint-rdoc --minter-addr "<minter addr>" --rbtc-to-mint "<rbtc to mint>" --network rskTestnet
```
