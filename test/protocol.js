const { expect } = require("chai");
const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const {colors} = require('colors');

describe("Derive", function () {

  const collID = 'My collection';
  const contracts = {};
  const users = [];

  let owner;
  let wallet1;
  let wallet2;
  let wallet3;

  let coll1;
  let coll2;
  let coll3;

  it("should deploy", async function(){

    [owner, wallet1, wallet2, wallet3] = await hre.ethers.getSigners();
    console.log(`   owner -> `, owner.address.yellow);
    console.log(`   wallet1 -> `, wallet1.address.red);
    console.log(`   wallet2 -> `, wallet2.address.yellow);
    console.log(`   wallet3 -> `, wallet3.address.red);

    const Polly = await ethers.getContractFactory("Polly");
    contracts.main = await Polly.deploy();

    const AuxMeta = await ethers.getContractFactory("AuxMeta");
    contracts.meta = await AuxMeta.deploy();

    const AuxArtwork = await ethers.getContractFactory("AuxArtwork");
    contracts.artwork = await AuxArtwork.deploy();

    console.log(`   Main contract -> `, contracts.main.address.green);
    console.log(`   Artwork contract -> `, contracts.artwork.address.green);
    console.log(`   Meta contract -> `, contracts.meta.address.green);

    users[1] = await contracts.main.connect(wallet1);
    users[2] = await contracts.main.connect(wallet2);
    users[3] = await contracts.main.connect(wallet3);
    expect(contracts.main.address).to.be.a.properAddress

  });

  it('should allow anyone to create a collection instance', async function(){

    await users[1].createCollection(collID, [contracts.artwork.address, contracts.meta.address]);
    const instance = await contracts.main.getCollectionInstance(collID);

    const Collection = await ethers.getContractFactory("Collection");

    console.log(`   Collection instance -> `, instance.coll.green);
    coll1 = await Collection.attach(instance.coll).connect(wallet1);

    expect(instance.coll).to.be.a.properAddress
    expect(instance.cat).to.be.a.properAddress

  });

  describe("Collection 1", async function(){

    it('can create edition', async function(){

      const edition = [
        "Greatest hits",
        "The Greatest Artist Alive",
        ethers.utils.parseEther('0.05'), // uint price;
        500, // uint supply;
        wallet1.address, // address recipient;
        [ // ICatalogue.ItemInput[] items;
          [
            "First track",
            "First artist",
            "filechecksum",
            ["https://link.to/media.wav"]
          ],
          [
            "Second track",
            "Second artist",
            "other-filechecksum",
            ["https://link.to/other-media.wav"]
          ]
        ],
      ];

      await coll1.createEdition(edition);

    });


    it('can output URI', async function(){
      const json = await coll1.uri(1);
      console.log(json);
      expect(1).to.equal(1);
    });

  });


});
