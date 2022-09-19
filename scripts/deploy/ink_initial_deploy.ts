
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
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
  const factoryManager = await factoryManagerFactory.deploy(configManager.address);
  await factoryManager.deployed();

  const theBoardFactory = await ethers.getContractFactory("TheBoard");
  const theBoard = await theBoardFactory.deploy();
  await theBoard.deployed();

  const thePublicFactory = await ethers.getContractFactory("ThePublic");
  const thePublic = await thePublicFactory.deploy();
  await thePublic.deployed();

  const treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
  const treasuryCommittee = await treasuryCommitteeFactory.deploy();
  await treasuryCommittee.deployed();

  const masterDAOFactory = await ethers.getContractFactory("MasterDAO");
  const masterDAO = await masterDAOFactory.deploy();
  await masterDAO.deployed();


  //init factory manager key
  console.log("useful constant ##################################################################################################################")
  console.log("deploy key ------------------------------------------------------------------ ")
  console.log("domain: ", admin);
  console.log("the board committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TheBoardCommittee"));
  console.log("the public committee key:", await configManager.buildConfigKey(admin, "ADMIN", "ThePublicCommittee"));
  console.log("the treasury committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TreasuryCommittee"));
  console.log("the master DAO key:", await configManager.buildConfigKey(admin, "ADMIN", "MasterDAO"));
  console.log("the factory manager key:", await configManager.buildConfigKey(admin, "ADMIN", "FactoryManager"));


  console.log("contract type ------------------------------------------------------------------ ")
  console.log("FactoryTypeID=", keccak256(toUtf8Bytes("FactoryTypeID")));
  console.log("DAOTypeID=", keccak256(toUtf8Bytes("DAOTypeID")));
  console.log("AgentTypeID=", keccak256(toUtf8Bytes("AgentTypeID")));
  console.log("CommitteeTypeID=", keccak256(toUtf8Bytes("CommitteeTypeID")));


  console.log("duty id ------------------------------------------------------------------ ")
  console.log("PROPOSER_DUTYID=", keccak256(toUtf8Bytes("PROPOSER_DUTYID")));
  console.log("VOTER_DUTYID=", keccak256(toUtf8Bytes("VOTER_DUTYID")));


  console.log("deployed address ##################################################################################################################")
  console.log("config address:", configManager.address);
  console.log("factory address:", factoryManager.address);

  /// init template
  var keyValues : any = [];
  keyValues[0] = {"keyPrefix":"ADMIN", "keyName":"FactoryManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await factoryManager.address)};
  keyValues[1] = {"keyPrefix":"ADMIN", "keyName":"TheBoardCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theBoard.address)}
  keyValues[2] = {"keyPrefix":"ADMIN", "keyName":"ThePublicCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await thePublic.address)}
  keyValues[3] = {"keyPrefix":"ADMIN", "keyName":"TreasuryCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await treasuryCommittee.address)}
  keyValues[4] = {"keyPrefix":"ADMIN", "keyName":"MasterDAO", "typeID":keccak256(toUtf8Bytes("address")), "data": (await masterDAO.address)}
  await configManager.batchSetKV(admin, keyValues);



}

deploy();