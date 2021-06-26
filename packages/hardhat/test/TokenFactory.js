const { expect } = require("chai");

describe("", () => {

    it("-- Testing PTokenFactory.sol ---", async function () {

// ---------------------
        // Variables
        let name; 
        let symbol;
        // let vintage;
        // let standard;
        // let country;
        
        projectIdentifier = "p001-CO-GS";
        projectIdentifier2 = "p002-CO-GS";
        serialNumber = "VCS-VCU-262-VER-BR-14-1686-01012017";

// ---------------------
        // Create Blockchain Accounts
        [owner, project, acc3, ...addrs] = await ethers.getSigners();
        console.log("\n------ ACCOUNTs --------")
        console.log("Account 1:", owner.address);
        console.log("Project:", project.address);
        console.log("-------------\n")

// ---------------------
        // BatchNFT minting
        console.log("\n----\nDeploying BatchCollection...");
        factory = await ethers.getContractFactory("BatchCollection");
        NFTcontract = await factory.deploy();
        console.log("\nBatchCollection address:");
        console.log(NFTcontract.address);
        console.log("\nConnecting Project Account and mint Batch-NFT...");
        await NFTcontract.connect(project).mintBatchWithData(project.address, projectIdentifier, "2016", serialNumber, 1000);


// ---------------------
        // Deploying ContractRegistry
        console.log("\n----\nDeploying ContractRegistry...");
        factory = await ethers.getContractFactory("ContractRegistry");
        registryC = await factory.deploy();
        console.log("Registry address:", registryC.address);
        console.log(`setBatchCollectionAddress(${NFTcontract.address})`);

        await registryC.setBatchCollectionAddress(NFTcontract.address);
        
// ---------------------
        // Deploying ProjectERC20Factory
        console.log("\n----\nDeploying ProjectERC20Factory:");
        factory = await ethers.getContractFactory("ProjectERC20Factory");  
        FactoryContract = await factory.deploy(registryC.address);

        name = "ProjectTreez"; 
        symbol = "CO-GS-16";
        vintage = "2016";

        console.log("Deploy new ProjectERC20 token via ProjectERC20Factory...");

        await FactoryContract.deployNewToken(name, symbol, projectIdentifier, vintage, registryC.address);
        // await FactoryContract.deployNewToken(name, symbol, projectIdentifier2, vintage, registryC.address);

        pERC20Array = await FactoryContract.getContracts();
        console.log("logging getContracts()", pERC20Array);
        // await FactoryContract.test();

        const tokenId = 1;
        expect(await NFTcontract.ownerOf(tokenId)).to.equal(project.address);
        console.log("Owner of NFT:", await NFTcontract.ownerOf(tokenId));
        console.log("NFT Confirmation status:", await NFTcontract.getConfirmationStatus(tokenId));
        console.log("Setting verifier=owner and confirming");
        await NFTcontract.setVerifier(owner.address);
        await NFTcontract.confirmRetirement(tokenId);
        console.log("NFT Confirmation status:", await NFTcontract.getConfirmationStatus(tokenId));
        // console.log(owner.address, pERC20Array[0]);

// ---------------------
        // Sending BatchNFTs to pERC20 contract

        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance owner:", await NFTcontract.balanceOf(owner.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(pERC20Array[0]));

        console.log("\n----Sending BatchNFT from Project to Account 1:");
        await NFTcontract.connect(project).transferFrom(project.address, owner.address, 1);
        // await NFTcontract.connect(project).safeTransferFrom(project.address, owner.address, 1);

        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance owner:", await NFTcontract.balanceOf(owner.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(pERC20Array[0]));

        console.log("\n----Sending BatchNFT from Account 1 to pERC20 contract:");
        await NFTcontract.connect(owner).transferFrom(owner.address, pERC20Array[0], 1);

        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance owner:", await NFTcontract.balanceOf(owner.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(pERC20Array[0]));

        let existingContract = await ethers.getContractAt("ProjectERC20", pERC20Array[0]);
        // console.log(existingContract);

        console.log("balance pERC20:", await existingContract.balanceOf(owner.address));

    });

});
