const { expect } = require("chai");
const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Derive", function () {

  const labelID = 'My label';
  const contracts = {};
  const users = [];
  
  let owner;
  let wallet1;
  let wallet2;
  let wallet3;

  let label1;
  let label2;
  let label3;

  it("should deploy", async function(){

    [owner, wallet1, wallet2, wallet3] = await hre.ethers.getSigners();
    const Main = await ethers.getContractFactory("Main");
    const Label = await ethers.getContractFactory("Label");
    const Catalogue = await ethers.getContractFactory("Catalogue");
    contracts.main = await Main.deploy();

    users[1] = await contracts.main.connect(wallet1);
    users[2] = await contracts.main.connect(wallet2);
    users[3] = await contracts.main.connect(wallet3);

    await users[1].createLabel(labelID);
    const proxy = await contracts.main.getLabelProxy(labelID);
    label1 = await Label.attach(proxy.label).connect(wallet1)
    cat1 = await Catalogue.attach(proxy.cat).connect(owner)
    cat1.addManager(proxy.label)

    expect(proxy.label).to.be.a.properAddress
    expect(proxy.cat).to.be.a.properAddress
    expect(proxy.art).to.be.a.properAddress
    expect(proxy.meta).to.be.a.properAddress

  });

  describe("label1", async function(){

    it('can create release', async function(){
      
      const release = [
        false, // bool released;
        ethers.utils.parseEther('0.05'), // uint price;
        500, // uint supply;
        wallet1.address, // address recipient_address;
        '0x0000000000000000000000000000000000000000', // address meta_address;
        '0x0000000000000000000000000000000000000000', // address artwork_address;
        [ // ICatalogue.Collection collection;
          "Greatest hits",
          "Elton John",
          "All rights reserved"
        ],
        [ // ICatalogue.ItemInput[] items;
          [
            "First track",
            "First artist",
            "Second track",
            "https://link.to/media"
          ]
        ],
      ];

      await label1.createRelease(release);

    });

  });

});
