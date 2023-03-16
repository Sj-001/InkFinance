
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

  /*

  config address: 0x335088193CDE7e1D05475AC2d28b89070a1b0C7e
  factory address: 0x33806C358917641D85fA1d5dCB3f41DF2F375482
  */
  const configManagerFactory = await ethers.getContractFactory("ConfigManager");
  const configManager = await configManagerFactory.attach("0xa6859cb0AfCB3b2B50E50655CdB9673EE34A1a77");

  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = await factoryManagerFactory.attach("0xBE436c748320E8810A74D9391f53d7FAc2908AAD");

  

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


  const incomeManagerSetupAgentFactory = await ethers.getContractFactory("IncomeManagerSetupAgent");
  const incomeManagerSetupAgentImpl = await incomeManagerSetupAgentFactory.deploy();
  await incomeManagerSetupAgentImpl.deployed();


  const treasuryIncomeManagerFactory = await ethers.getContractFactory("TreasuryIncomeManager");
  const treasuryIncomeManagerImpl = await treasuryIncomeManagerFactory.deploy();
  await treasuryIncomeManagerImpl.deployed();

  const inkBadgeERC20Factory = await ethers.getContractFactory("InkBadgeERC20");
  const inkBadgeERC20Impl = await inkBadgeERC20Factory.deploy();
  await inkBadgeERC20Impl.deployed();


  //init factory manager key
  console.log("useful constant ################################################################################################################## ")
  
  
  
  
  console.log("domain: ", admin);
  console.log("");
  
  
  console.log("duty id ------------------------------------------------------------------ ")
  console.log("PROPOSER=", keccak256(toUtf8Bytes("dutyID.PROPOSER")));
  console.log("VOTER=", keccak256(toUtf8Bytes("dutyID.VOTER")));
  console.log("SIGNER=", keccak256(toUtf8Bytes("dutyID.SIGNER")));
  console.log("OPERATOR=", keccak256(toUtf8Bytes("dutyID.OPERATOR")));
  console.log("AUDITOR=", keccak256(toUtf8Bytes("dutyID.AUDITOR")));
  console.log("");

  console.log("deploy key ------------------------------------------------------------------ ")
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
  console.log("the income agent key:", await configManager.buildConfigKey(admin, "ADMIN", "IncomeManagerSetupAgent"));
  console.log("the income manager key:", await configManager.buildConfigKey(admin, "ADMIN", "TreasuryIncomeManager"));
  console.log("the ink badge erc20 key:", await configManager.buildConfigKey(admin, "ADMIN", "InkBadgeERC20"));

  console.log("contract type ------------------------------------------------------------------ ")
  console.log("FactoryTypeID=", keccak256(toUtf8Bytes("FactoryTypeID")));
  console.log("DAOTypeID=", keccak256(toUtf8Bytes("DAOTypeID")));
  console.log("AgentTypeID=", keccak256(toUtf8Bytes("AgentTypeID")));
  console.log("CommitteeTypeID=", keccak256(toUtf8Bytes("CommitteeTypeID")));
  console.log("");



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
  keyValues[11] = {"keyPrefix":"ADMIN", "keyName":"IncomeManagerSetupAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await incomeManagerSetupAgentImpl.address)}
  keyValues[12] = {"keyPrefix":"ADMIN", "keyName":"TreasuryIncomeManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await treasuryIncomeManagerImpl.address)}
  keyValues[13] = {"keyPrefix":"ADMIN", "keyName":"InkBadgeERC20", "typeID":keccak256(toUtf8Bytes("address")), "data": (await inkBadgeERC20Impl.address)}
  
  await configManager.batchSetKV(admin, keyValues);



}

deploy();