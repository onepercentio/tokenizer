const { expect } = require("chai");
// const { ethers } = require("hardhat-ethers");

describe("", () => {
  it("-- Overall deployment test flow ---", async function () {
    // ---------------------
    // Variables

    const name = "ProjectTreez";
    const symbol = "CO-GS-16";
    const vintage = 2016;

    const projectIdentifier = "p001-CO-GS";
    const projectIdentifier2 = "p002-CO-GS";
    const serialNumber = "VCS-VCU-262-VER-BR-14-1686-01012017";

    // ---------------------
    // Create Blockchain Accounts;

    const [owner, project] = await ethers.getSigners();
    console.log("\n------ ACCOUNTs --------");
    console.log("Account 1:", owner.address);
    console.log("Project:", project.address);
    console.log("-------------\n");

    // ---------------------
    // Deploying ContractRegistry
    console.log("\n----\nDeploying ContractRegistry...");
    factory = await ethers.getContractFactory("ContractRegistry");
    ContractRegistry = await factory.deploy();
    console.log("Registry address:", ContractRegistry.address);

    // ---------------------
    // Deploying BatchCollection
    console.log("\n----\nDeploying BatchCollection...");
    factory = await ethers.getContractFactory("BatchCollection");
    BatchCollection = await factory.deploy(ContractRegistry.address);
    console.log("\nBatchCollection address:");
    console.log(BatchCollection.address);

    // ---------------------
    // BatchNFT minting
    console.log("\nConnecting Project Account and mint Batch-NFT...");
    await BatchCollection.connect(project).mintBatchWithData(
      project.address,
      projectIdentifier,
      "2016",
      serialNumber,
      1000
    );


    console.log(`setBatchCollectionAddress(${BatchCollection.address})`);
    await ContractRegistry.setBatchCollectionAddress(BatchCollection.address);

    // ---------------------
    // Deploying ProjectERC20Factory
    console.log("\n----\nDeploying ProjectERC20Factory:");
    factory = await ethers.getContractFactory("ProjectERC20Factory");
    // deploy and pass registry address to contructor
    ProjectERC20Factory = await factory.deploy(ContractRegistry.address);
    console.log(`setProjectERC20FactoryAddress(${ProjectERC20Factory.address})`);
    await ContractRegistry.setProjectERC20FactoryAddress(ProjectERC20Factory.address);


    // ---------------------
    // Deploying new pERC20 tokens
    console.log("Deploy new ProjectERC20 token via ProjectERC20Factory...");
    // await ProjectERC20Factory.deployNewToken(
    //   name,
    //   symbol,
    //   projectIdentifier,
    //   vintage,
    //   ContractRegistry.address
    // );
    // await ProjectERC20Factory.deployNewToken(
    //   name,
    //   symbol,
    //   projectIdentifier2,
    //   vintage,
    //   ContractRegistry.address
    // );

    console.log("Deploying new ProjectERC20 from template...");
    const tokenId = 1;
    await ProjectERC20Factory.deployFromTemplate(tokenId);
    
    // retrieve array with all erc20 contract addresses
    pERC20Array = await ProjectERC20Factory.getContracts();
    console.log("logging getContracts()", pERC20Array);
    // await ProjectERC20Factory.test();

    expect(await BatchCollection.ownerOf(tokenId)).to.equal(project.address);
    console.log("Owner of NFT:", await BatchCollection.ownerOf(tokenId));
    console.log(
      "NFT Confirmation status:",
      await BatchCollection.getConfirmationStatus(tokenId)
    );
    console.log("Setting verifier=owner and confirming");
    await BatchCollection.setVerifier(owner.address);
    await BatchCollection.confirmRetirement(tokenId);
    console.log(
      "NFT Confirmation status:",
      await BatchCollection.getConfirmationStatus(tokenId)
    );
    // console.log(owner.address, pERC20Array[0]);

    // ---------------------
    // Sending BatchNFTs to pERC20 contract

    console.log("balance project:", await BatchCollection.balanceOf(project.address));
    console.log("owner of token:", await BatchCollection.ownerOf(tokenId));
    console.log("balance owner:", await BatchCollection.balanceOf(owner.address));
    console.log("balance pERC20:", await BatchCollection.balanceOf(pERC20Array[0]));

    console.log("\n----Sending BatchNFT from Project to Account 1:");
    await BatchCollection.connect(project).transferFrom(project.address, owner.address, 1);

    console.log(
      "balance project:",
      await BatchCollection.balanceOf(project.address)
    );
    console.log("balance owner:", await BatchCollection.balanceOf(owner.address));
    console.log("balance pERC20:", await BatchCollection.balanceOf(pERC20Array[0]));

    console.log("\n----Sending BatchNFT from Account 1 to pERC20 contract:");
    await BatchCollection.connect(owner).transferFrom(
      owner.address,
      pERC20Array[0],
      1
    );

    console.log(
      "balance project:",
      await BatchCollection.balanceOf(project.address)
    );
    console.log("balance owner:", await BatchCollection.balanceOf(owner.address));
    console.log("balance pERC20:", await BatchCollection.balanceOf(pERC20Array[0]));

    const existingContract = await ethers.getContractAt(
      "ProjectERC20",
      pERC20Array[0]
    );
    // console.log(existingContract);

    console.log(
      "balance pERC20:",
      await existingContract.balanceOf(owner.address)
    );

    console.log(await ContractRegistry.projectERC20FactoryAddress());

  });
});
