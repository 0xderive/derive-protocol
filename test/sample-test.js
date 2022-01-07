const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Derive", function () {

  const contracts = {};
  const users = {};

  it("should deploy", async function(){
    
    const Main = await ethers.getContractFactory("Main");
    contracts.main = await Main.deploy();

    await contracts.main.createLabel("derive");
    const proxy = await contracts.main.getLabelProxy("derive");

    expect(proxy).to.be.a.properAddress

  });

});
