
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

import {ethers, upgrades} from "hardhat";

// constant define

async function deploy(){

  // initial roles
  const signers = await ethers.getSigners();
  // admin
  var admin = signers[0].address;

  const configManagerFactory = await ethers.getContractFactory("ConfigManager");
  const configManager = await configManagerFactory.deploy();
  await configManager.deployed();

  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = await factoryManagerFactory.deploy();
  await factoryManager.deployed();


  //init factory manager key
  console.log("useful constant ##################################################################################################################")

  console.log("domain: ", admin);
  console.log("the board committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TheBoardCommittee"));
  console.log("the public committee key:", await configManager.buildConfigKey(admin, "ADMIN", "ThePublicCommittee"));
  console.log("the treasury committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TreasuryCommittee"));
  console.log("the master DAO key:", await configManager.buildConfigKey(admin, "ADMIN", "MasterDAO"));


  console.log("deployed address ##################################################################################################################")
  console.log("config address:", configManager.address);
  console.log("factory address:", factoryManager.address);





}

deploy();