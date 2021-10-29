const { expect } = require("chai");
const { ethers } = require("hardhat");
const {ContractFactory, utils, BigNumber} = require('ethers');

describe("TheDAONFT", function () {

  let TheNft;
  let nft;
  let TheDAOMock; // fake thedao contract
  let theDao; // instance of TheDAOMock
  let owner, simp, elizabeth; // test accounts

  let ASSET_URL = "ipfs://2727838744/something/238374/";

  let feth = utils.formatEther;
  let peth = utils.parseEther;

  //                  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  let DEAD_ADDRESS = "0x000000000000000000000000000000000074eda0";
  let ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  before(async function () {

    [owner, simp, elizabeth] = await ethers.getSigners();


    // deploy the TheDAO mocking contract
    TheDAOMock = await ethers.getContractFactory("TheDAOMock");
    theDao = await TheDAOMock.deploy(owner.address);
    await theDao.deployed();


    TheNFT = await ethers.getContractFactory("TheNFT");
    nft = await TheNFT.deploy(theDao.address, 180);
    await nft.deployed();

    await theDao.setNFT(nft.address);

  });

  it("Should set asset URLs and admin", async function () {

    expect(await nft.setCurator(owner.address)).to.emit(nft, 'Curator').withArgs(owner.address);

    expect(await nft.setBaseURI(ASSET_URL)).to.emit(nft, 'BaseURI').withArgs(ASSET_URL);

    expect(await nft.tokenURI(179)).to.be.equal(ASSET_URL + "179");

    expect(await nft.tokenURI(0)).to.be.equal(ASSET_URL + "0");

    // set "setCurator"" should be rejected
    await expect( nft.connect(simp).setCurator(elizabeth.address)).to.be.revertedWith("only curator can call this");

    await expect(nft.connect(simp).setBaseURI("http://test.com/")).to.be.revertedWith("only curator can call this");

  });

  it("Should mint some NFTs", async function () {

    // not approved
    await expect( nft.mint()).to.be.revertedWith("not approved");

    // nft contract has 180 nft ready to mint
    expect(await nft.balanceOf(nft.address)).to.be.equal(180);

    // approve
    expect(await theDao.approve(nft.address, peth("10"))).to.emit(theDao, 'Approval').withArgs(owner.address, nft.address, peth("10"));

    // now we can mint
    for (let i = 0; i < 180; i++) {
      console.log(i);
      expect(await nft.mint()).to.emit(nft, 'Mint').withArgs(owner.address, i);
    }
    // all minted, we cannot mint anymore
    await expect( nft.mint()).to.be.revertedWith("minting finished");

    // I should have 180 nft
    expect(await nft.balanceOf(owner.address)).to.be.equal(180);

    // nft contract has 0 nft ready to mint
    expect(await nft.balanceOf(nft.address)).to.be.equal(0);

    // the NFT contract should hold 180 DAO
    expect(await theDao.balanceOf(nft.address)).to.be.equal(peth("1.8"));

  });

  it("It should transfer NFTs", async function () {
    // ensure we cannot send to DEAD
    await expect( nft.transferFrom(owner.address, DEAD_ADDRESS, 42)).to.be.revertedWith("cannot send to dead address");

    // ensure we cannot send to self
    await expect( nft.transferFrom(owner.address, nft.address, 42)).to.be.revertedWith("cannot send to self");

    // ensure we cannot send to 0
    await expect( nft.transferFrom(owner.address, ZERO_ADDRESS, 42)).to.be.revertedWith("cannot send to 0x");

    // test without approval (will revert since the mock is not approved
    await expect( theDao.testTransferFrom(owner.address, simp.address, 42)).to.be.revertedWith("not permitted");

    // test with approval

    expect(await nft.setApprovalForAll(theDao.address, true)).to.emit(nft, 'ApprovalForAll').withArgs(owner.address, theDao.address, true);
    console.log("owner add:", owner.address);
    console.log("simp add:", simp.address);
    // try the transfer again
    expect(await theDao.testTransferFrom(owner.address, simp.address, 42)).to.emit(nft, 'Transfer').withArgs(owner.address, simp.address, 42);

    expect(await nft.balanceOf(simp.address)).to.be.equal(1);

    // simp account should have 1 NFT

    stats = await nft.getStats(simp.address);
console.log(stats);
    expect(stats[0]).to.be.equal(peth('0')); // 0 dao tokens
    expect(stats[1]).to.be.equal(peth('0')); // 0 allowance
    expect(stats[2]).to.be.equal(peth('0.000001'));
    expect(stats[3]).to.be.equal(peth('0.000001'));
    expect(stats[4]).to.be.equal(peth('0.000001'));


  });

  it("Should burn and restore NFTs", async function () {


  });



  it("Should report the stats", async function () {


  });

  it("Should do all the other things", async function () {

  })





});
