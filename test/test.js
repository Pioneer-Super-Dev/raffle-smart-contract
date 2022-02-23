const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Infini Space NFT minting test", function () {
  it("minting test", async function () {
    this.timeout(100000);
    const baseTokenURI = "https://gateway.pinata.cloud/ipfs/";
    const nftContractFactory = await ethers.getContractFactory(
      "InfiniSpaceNFT"
    );
    const nft = await nftContractFactory.deploy(baseTokenURI);
    const deployed_nft = await nft.deployed();

    console.log(`Smart Contract Address: ${deployed_nft.address}`);

    const deploy_token_mint = await nft.mint(
      "0x633Ca16C4D7CC0d047b25BB013269Abb513d1812",
      "ai123i123i2"
    );
    const deploy_token_mint_await = await deploy_token_mint.wait();
    const tokenID = Number(deploy_token_mint_await.events[0].topics[3]);
    console.log("Token ID = ", tokenID);
    expect(tokenID).to.equal(1);
  });
});
