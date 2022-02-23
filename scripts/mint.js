const { task } = require("hardhat/config");
const { getContract } = require("./helpers");

task("mint", "Mints from the NFT contract")
  .addParam("address", "The address to receive a token")
  .addParam("hash", "The IPFS hash value")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("InfiniSpaceNFT", hre);
    const transactionResponse = await contract.mint(
      taskArguments.address,
      taskArguments.hash,
      {
        gasLimit: 500_000,
      }
    );
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });
