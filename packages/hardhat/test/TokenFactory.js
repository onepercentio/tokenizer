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
        [acc1, project, acc3, ...addrs] = await ethers.getSigners();
        console.log("\n------ ACCOUNTs --------")
        console.log("acc1 address:", acc1.address);
        console.log("project address:", project.address);
        console.log("-------------\n")

        rawMsg = await acc1.signMessage("Retiring Serial No: 123");
        console.log("Logging signed message:", rawMsg);

// ---------------------
        // BatchNFT minting
        console.log("\n----Deploying BatchCollection:");
        factory = await ethers.getContractFactory("BatchCollection");
        NFTcontract = await factory.deploy();
        console.log("\n----BatchCollection address:");
        console.log(NFTcontract.address);
        await NFTcontract.connect(project).mintBatchWithData(project.address, projectIdentifier, "2016", serialNumber, 1000);


        name = "ProjectTreez"; 
        symbol = "CO-GS-16";
        vintage = "2016";
    
// ---------------------
        // Deploying ContractRegistry
        console.log("\n----Deploying ContractRegistry:");
        factory = await ethers.getContractFactory("ContractRegistry");
        registryC = await factory.deploy();
        console.log("\n----registry address:");
        console.log(registryC.address);

        await registryC.setBatchCollectionAddress(NFTcontract.address);
        
// ---------------------
        // Deploying ProjectERC20Factory
        console.log("\n----Deploying ProjectERC20Factory:");
        factory = await ethers.getContractFactory("ProjectERC20Factory");  
        FactoryContract = await factory.deploy();

        // console.log("Deploying pERC20 token:")
        await FactoryContract.deployNewToken(name, symbol, projectIdentifier, vintage, registryC.address);
        await FactoryContract.deployNewToken(name, symbol, projectIdentifier2, vintage, registryC.address);

        response = await FactoryContract.getContracts();
        console.log("logging getContracts()", response);
        // await FactoryContract.test();

        const tokenId = 1;
        expect(await NFTcontract.ownerOf(tokenId)).to.equal(project.address);
        console.log("Owner of NFT:", await NFTcontract.ownerOf(tokenId));

        // console.log(acc1.address, response[0]);

// ---------------------
        // Sending BatchNFTs to pERC20 contract
        console.log("\n----Sending BatchNFTs:");
        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance acc1:", await NFTcontract.balanceOf(acc1.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(response[0]));

        await NFTcontract.connect(project).transferFrom(project.address, acc1.address, 1);
        // await NFTcontract.connect(project).safeTransferFrom(project.address, acc1.address, 1);

        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance acc1:", await NFTcontract.balanceOf(acc1.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(response[0]));

        await NFTcontract.connect(acc1).transferFrom(acc1.address, response[0], 1);

        console.log("balance project:", await NFTcontract.balanceOf(project.address));
        console.log("balance acc1:", await NFTcontract.balanceOf(acc1.address));
        console.log("balance pERC20:", await NFTcontract.balanceOf(response[0]));


    });

});
