const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TheDAONFT", function () {

  let TheNft;
  let nft;
  let TheDAOMock; // fake thedao contract
  let theDao; // instance of TheDAOMock
  let owner, simp, elizabeth; // test accounts

  let ASSET_URL = "ipfs://2727838744/something/238374/";

  before(async function () {

    [owner, simp, elizabeth] = await ethers.getSigners();


    // deploy the TheDAO mocking contract
    TheDAOMock = await ethers.getContractFactory("TheDAOMock");
    theDao = await TheDAOMock.deploy(owner.address);
    await theDao.deployed();


    TheNFT = await ethers.getContractFactory("TheNFT");
    nft = await TheNFT.deploy(theDao.address);
    await nft.deployed();



    // test setting the asset URI

    //await expect(nft.setURI(ASSET_URL)).to.be.revertedWith('only admin can call this');

  });

  it("Should set asset URLs and admin", async function () {

    expect(await nft.setCurator(owner.address)).to.emit(nft, 'Curator').withArgs(owner.address);

    expect(await nft.setBaseURI(ASSET_URL)).to.emit(nft, 'BaseURI').withArgs(ASSET_URL);

    expect(await nft.tokenURI(1699)).to.be.equal(ASSET_URL + "1699");
    expect(await nft.tokenURI(0)).to.be.equal(ASSET_URL + "0");

    // set "setCurator"" should be rejected
    await expect( nft.connect(simp).setCurator(elizabeth.address)).to.be.revertedWith("only curator can call this");

    await expect(nft.connect(simp).setBaseURI("http://test.com/")).to.be.revertedWith("only curator can call this");




  });





});
