const { utils } = require("ethers");

async function main() {
  // Get contract that we want to deploy
  const contractFactory = await hre.ethers.getContractFactory(
    "RaffleTestToken"
  );

  // Deploy contract with the correct constructor arguments
  const contract = await contractFactory.deploy();

  // Wait for this transaction to be mined
  await contract.deployed();

  // // Get contract address
  console.log("Raffle Token Contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
