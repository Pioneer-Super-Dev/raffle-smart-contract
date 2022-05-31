const { utils } = require("ethers");

async function main() {
  // Get contract that we want to deploy
  const contractFactory = await hre.ethers.getContractFactory("Raffle");

  // Deploy contract with the correct constructor arguments
  const contract = await contractFactory.deploy(
    "0xb060B9bf15b374d9EF692abECE39180bAAAC0Cad"
  );

  // Wait for this transaction to be mined
  await contract.deployed();

  // // Get contract address
  console.log("Raffle Contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
