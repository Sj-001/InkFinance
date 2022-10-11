
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
  console.log("deploy InkFinance Governance Module V2 with this account: ", admin);


  const configManagerFactory = await ethers.getContractFactory("ConfigManager");
  const configManager = await configManagerFactory.deploy();
  await configManager.deployed();

  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = await factoryManagerFactory.deploy(configManager.address);
  await factoryManager.deployed();

  const theBoardFactory = await ethers.getContractFactory("TheBoard");
  const theBoardCommitteeImpl = await theBoardFactory.deploy();
  await theBoardCommitteeImpl.deployed();

  const thePublicFactory = await ethers.getContractFactory("ThePublic");
  const thePublicCommitteeImpl = await thePublicFactory.deploy();
  await thePublicCommitteeImpl.deployed();

  const treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
  const theTreasuryCommitteeImpl = await treasuryCommitteeFactory.deploy();
  await theTreasuryCommitteeImpl.deployed();

  const masterDAOFactory = await ethers.getContractFactory("MasterDAO");
  const masterDAOImpl = await masterDAOFactory.deploy();
  await masterDAOImpl.deployed();

  const treasuryManagerAgentFactory = await ethers.getContractFactory("TreasuryManagerAgent");
  const theTreasuryManagerAgentImpl = await treasuryManagerAgentFactory.deploy();
  await theTreasuryManagerAgentImpl.deployed();

  const payrollSetupAgentFactory = await ethers.getContractFactory("PayrollSetupAgent");
  const payrollSetupAgentImpl = await payrollSetupAgentFactory.deploy();
  await payrollSetupAgentImpl.deployed();


  const payrollExecuteAgentFactory = await ethers.getContractFactory("PayrollExecuteAgent");
  const payrollExecuteAgentImpl = await payrollExecuteAgentFactory.deploy();
  await payrollExecuteAgentImpl.deployed();


  const payrollUCVManagerAgentFactory = await ethers.getContractFactory("PayrollUCVManager");
  const payrollUCVManagerImpl = await payrollUCVManagerAgentFactory.deploy();
  await payrollUCVManagerImpl.deployed();


  const payrollUCVFactory = await ethers.getContractFactory("PayrollUCV");
  const payrollUCVImpl = await payrollUCVFactory.deploy();
  await payrollUCVImpl.deployed();


  const proposalHandlerFactory = await ethers.getContractFactory("ProposalHandler");
  const proposalHandlerImpl = await proposalHandlerFactory.deploy();
  await proposalHandlerImpl.deployed();


  //init factory manager key
  console.log("useful constant ################################################################################################################## ")
  console.log("deploy key ------------------------------------------------------------------ ")
  console.log("domain: ", admin);
  console.log("");
  console.log("the board committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TheBoardCommittee"));
  console.log("the public committee key:", await configManager.buildConfigKey(admin, "ADMIN", "ThePublicCommittee"));
  console.log("the treasury committee key:", await configManager.buildConfigKey(admin, "ADMIN", "TreasuryCommittee"));
  console.log("the master DAO key:", await configManager.buildConfigKey(admin, "ADMIN", "MasterDAO"));
  console.log("the factory manager key:", await configManager.buildConfigKey(admin, "ADMIN", "FactoryManager"));
  console.log("the treasury manager agent key:", await configManager.buildConfigKey(admin, "ADMIN", "TreasuryManagerAgent"));
  console.log("the payroll setup agent key:", await configManager.buildConfigKey(admin, "ADMIN", "PayrollSetupAgent"));
  console.log("the payroll execute agent key:", await configManager.buildConfigKey(admin, "ADMIN", "PayrollExecuteAgent"));
  console.log("the payroll ucv manager key:", await configManager.buildConfigKey(admin, "ADMIN", "PayrollUCVManager"));
  console.log("the payroll ucv key:", await configManager.buildConfigKey(admin, "ADMIN", "PayrollUCV"));
  console.log("the proposal handler key:", await configManager.buildConfigKey(admin, "ADMIN", "ProposalHandler"));

  console.log("contract type ------------------------------------------------------------------ ")
  console.log("FactoryTypeID=", keccak256(toUtf8Bytes("FactoryTypeID")));
  console.log("DAOTypeID=", keccak256(toUtf8Bytes("DAOTypeID")));
  console.log("AgentTypeID=", keccak256(toUtf8Bytes("AgentTypeID")));
  console.log("CommitteeTypeID=", keccak256(toUtf8Bytes("CommitteeTypeID")));
  console.log("");

  console.log("duty id ------------------------------------------------------------------ ")
  console.log("PROPOSER_DUTYID=", keccak256(toUtf8Bytes("PROPOSER_DUTYID")));
  console.log("VOTER_DUTYID=", keccak256(toUtf8Bytes("VOTER_DUTYID")));
  console.log("");


  console.log("deployed address ##################################################################################################################")
  console.log("config address:", configManager.address);
  console.log("factory address:", factoryManager.address);

  /// init template
  var keyValues : any = [];
  keyValues[0] = {"keyPrefix":"ADMIN", "keyName":"FactoryManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await factoryManager.address)}
  keyValues[1] = {"keyPrefix":"ADMIN", "keyName":"TheBoardCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theBoardCommitteeImpl.address)}
  keyValues[2] = {"keyPrefix":"ADMIN", "keyName":"ThePublicCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await thePublicCommitteeImpl.address)}
  keyValues[3] = {"keyPrefix":"ADMIN", "keyName":"TreasuryCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theTreasuryCommitteeImpl.address)}
  keyValues[4] = {"keyPrefix":"ADMIN", "keyName":"MasterDAO", "typeID":keccak256(toUtf8Bytes("address")), "data": (await masterDAOImpl.address)}
  keyValues[5] = {"keyPrefix":"ADMIN", "keyName":"TreasuryManagerAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theTreasuryManagerAgentImpl.address)}
  keyValues[6] = {"keyPrefix":"ADMIN", "keyName":"PayrollUCV", "typeID":keccak256(toUtf8Bytes("address")), "data": (await payrollUCVImpl.address)}
  keyValues[7] = {"keyPrefix":"ADMIN", "keyName":"PayrollSetupAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await payrollSetupAgentImpl.address)}
  keyValues[8] = {"keyPrefix":"ADMIN", "keyName":"PayrollExecuteAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await payrollExecuteAgentImpl.address)}
  keyValues[9] = {"keyPrefix":"ADMIN", "keyName":"PayrollUCVManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await payrollUCVManagerImpl.address)}
  keyValues[10] = {"keyPrefix":"ADMIN", "keyName":"ProposalHandler", "typeID":keccak256(toUtf8Bytes("address")), "data": (await proposalHandlerImpl.address)}
  
  await configManager.batchSetKV(admin, keyValues);



}

deploy();