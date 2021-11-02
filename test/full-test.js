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

  let TOTAL_SUPPLY = 180;
  let RESTORE_FEE = 4;

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
    nft = await TheNFT.deploy(theDao.address, TOTAL_SUPPLY);
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

    // nft contract has TOTAL_SUPPLY nft ready to mint
    expect(await nft.balanceOf(nft.address)).to.be.equal(TOTAL_SUPPLY);

    // approve
    expect(await theDao.approve(nft.address, peth("10"))).to.emit(theDao, 'Approval').withArgs(owner.address, nft.address, peth("10"));

    // now we can mint
    for (let i = 0; i < TOTAL_SUPPLY; i++) {
      console.log(i);
      expect(await nft.mint()).to.emit(nft, 'Mint').withArgs(owner.address, i);
    }
    // all minted, we cannot mint anymore
    await expect( nft.mint()).to.be.revertedWith("minting finished");

    // I should have TOTAL_SUPPLY nft
    expect(await nft.balanceOf(owner.address)).to.be.equal(TOTAL_SUPPLY);

    // nft contract has 0 nft ready to mint
    expect(await nft.balanceOf(nft.address)).to.be.equal(0);

    // the NFT contract should hold TOTAL_SUPPLY DAO
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

    // try the transfer again
    expect(await theDao.testTransferFrom(owner.address, simp.address, 42)).to.emit(nft, 'Transfer').withArgs(owner.address, simp.address, 42);

    // simp should have 1 NFT now
    expect(await nft.balanceOf(simp.address)).to.be.equal(1);

    // simp account should have 1 NFT

    stats = await nft.getStats(simp.address);

    expect(stats[0]).to.be.equal(peth('0')); // 0 dao tokens
    expect(stats[1]).to.be.equal(peth('0')); // 0 allowance
    expect(stats[2]).to.be.equal(0);
    expect(stats[3]).to.be.equal(peth('0'));
    expect(stats[4]).to.be.equal(peth(TOTAL_SUPPLY+"").div("100")); // TOTAL_SUPPLY DAO

    // test safeTransferFrom
    await expect( nft['safeTransferFrom(address,address,uint256)'](owner.address, simp.address, 52)).to.emit(nft, 'Transfer').withArgs(owner.address, simp.address, 52);

    stats = await nft.getStats(simp.address);
    expect(stats[5]).to.be.equal(2); // simp should have 2 nfts now

    // test with individual approval (simp approves nft-52 to elizabeth)

    expect(await nft.connect(simp).approve(elizabeth.address, 52)).to.emit(nft, 'Approval').withArgs(simp.address, elizabeth.address, 52);

    // check approval
    expect(await nft.getApproved(52)).to.be.equal(elizabeth.address);

    // now elizabeth's turn to take it, she has permission
    // note that permission would be reset

    await expect( nft.connect(elizabeth)['safeTransferFrom(address,address,uint256)'](simp.address, owner.address, 52)).to.emit(nft, 'Transfer').withArgs(simp.address, owner.address, 52).to.emit(nft, 'Approval').withArgs(elizabeth.address, "0x0000000000000000000000000000000000000000", 52);

    // after transfer, the approval should be reset (elizabeth does not have approval)
    expect(await nft.getApproved(52)).to.be.equal("0x0000000000000000000000000000000000000000");

  });

  it("Should burn and restore NFTs", async function () {
    await expect(nft.burn(52)).to.emit(nft, "Burn").withArgs(owner.address, 52)
        .to.emit(theDao, "Transfer").withArgs(nft.address, owner.address, peth("1").div("100"));

    // check the state
    stats = await nft.getStats(owner.address);

    let expectedDAO = peth("200").sub(peth(TOTAL_SUPPLY+"").div("100")); // start with 20000 , minus 1800
    expectedDAO = expectedDAO.add(peth("1").div("100")); //  add 1 dao we received after burning

    expect(stats[0]).to.be.equal(expectedDAO); // 1 extra dao token
    expect(stats[3]).to.be.equal(1); // 1 NFT in the dead address

    // set the curator to be elizabeth so commissions go to her
    expect(await nft.setCurator(elizabeth.address)).to.emit(nft, 'Curator').withArgs(elizabeth.address);

    // restore the NFT, elizabeth will get the fee, nft will store 1 dao
    await expect(nft.restore(52)).to.emit(nft, "Restore").withArgs(owner.address, 52).to.emit(theDao, "Transfer").withArgs(owner.address, elizabeth.address, peth(RESTORE_FEE+"").div("100")).to.emit(theDao, "Transfer").withArgs(owner.address, nft.address, peth("1").div("100")).to.emit(nft, "Transfer").withArgs(DEAD_ADDRESS, owner.address, 52);

    // check the state
    stats = await nft.getStats(owner.address);

    expect(stats[0]).to.be.equal(expectedDAO.sub(peth("5").div("100"))); // owner should have 5 DAO less
  });



  it("Should report the stats", async function () {


  });

  it("Should do all the other things", async function () {
    // tokenByIndex

    // tokenOfOwnerByIndex

    //ownerOf

    // isApprovedForAll


  })





});
