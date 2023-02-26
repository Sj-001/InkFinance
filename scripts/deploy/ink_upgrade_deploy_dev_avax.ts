
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

import {ethers, upgrades} from "hardhat";

// when we have previous 

async function deploy(){

  // initial roles
  const signers = await ethers.getSigners();
  // admin
  var admin = signers[0].address;
  console.log("deploy InkFinance Governance Module V2 with this account: ", admin);


  const configManagerFactory = await ethers.getContractFactory("ConfigManager");
  const configManager = await configManagerFactory.attach("0xb3540A06A96a7B0763ad668F17bb81525bf66a8B");
  await configManager.deployed();
  console.log("config manager deployed..")

  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = factoryManagerFactory.attach("0x6e1E465c8C8E9aFaFC1B1C6594DAf5C0baDFA8C0")
  await factoryManager.deployed();

  console.log("factory deployed")

  const theBoardFactory = await ethers.getContractFactory("TheBoard");
  const theBoardCommitteeImpl = await theBoardFactory.deploy();
  await theBoardCommitteeImpl.deployed();
  console.log("the board deployed..")

  const thePublicFactory = await ethers.getContractFactory("ThePublic");
  const thePublicCommitteeImpl = await thePublicFactory.deploy();
  await thePublicCommitteeImpl.deployed();

  console.log("ThePublic deployed..")

  const treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
  const theTreasuryCommitteeImpl = await treasuryCommitteeFactory.deploy();
  await theTreasuryCommitteeImpl.deployed();

  console.log("ThePublic deployed..")

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


  const investmentCommitteeFactory = await ethers.getContractFactory("InvestmentCommittee");
  const investmentCommitteeImpl = await investmentCommitteeFactory.deploy();
  await investmentCommitteeImpl.deployed();

  const investmentManagementSetupAgentFactory = await ethers.getContractFactory("InvestmentManagementSetupAgent");
  const investmentManagementSetupAgentImpl = await investmentManagementSetupAgentFactory.deploy();
  await investmentManagementSetupAgentImpl.deployed();


  const InvestmentUCVManagerFactory = await ethers.getContractFactory("InvestmentUCVManager");
  const investmentUCVManagerImpl = await InvestmentUCVManagerFactory.deploy();
  await investmentUCVManagerImpl.deployed();


  const InvestmentUCVFactory = await ethers.getContractFactory("InvestmentUCV");
  const investmentUCVImpl = await InvestmentUCVFactory.deploy();
  await investmentUCVImpl.deployed();



  const FundManagerFactory = await ethers.getContractFactory("FundManager");
  const fundManagerImpl = await FundManagerFactory.deploy();
  await fundManagerImpl.deployed();

  console.log("FundManager deployed..")


  const InkFundFactory = await ethers.getContractFactory("InkFund");
  const inkFundImpl = await InkFundFactory.deploy();
  await inkFundImpl.deployed();

  console.log("InkFund deployed..")


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
  console.log("FUND_ADMIN=", keccak256(toUtf8Bytes("dutyID.FUND_ADMIN")));
  console.log("FUND_MANAGER=", keccak256(toUtf8Bytes("dutyID.FUND_MANAGER")));
  console.log("FUND_RISK_MANAGER=", keccak256(toUtf8Bytes("dutyID.FUND_RISK_MANAGER")));
  console.log("FUND_LIQUIDATOR=", keccak256(toUtf8Bytes("dutyID.FUND_LIQUIDATOR")));
  console.log("FUND_AUDITOR=", keccak256(toUtf8Bytes("dutyID.FUND_AUDITOR")));

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
  console.log("the investment committee key:", await configManager.buildConfigKey(admin, "ADMIN", "InvestmentCommittee"));
  console.log("the investment committee setup agent key:", await configManager.buildConfigKey(admin, "ADMIN", "InvestmentManagementSetupAgent"));
  console.log("the investment manager key:", await configManager.buildConfigKey(admin, "ADMIN", "InvestmentUCVManager"));
  console.log("the investment ucv key:", await configManager.buildConfigKey(admin, "ADMIN", "InvestmentUCV"));
  console.log("the fund manager key:", await configManager.buildConfigKey(admin, "ADMIN", "FundManager"));
  console.log("the ink fund key:", await configManager.buildConfigKey(admin, "ADMIN", "InkFund"));


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
  keyValues[14] = {"keyPrefix":"ADMIN", "keyName":"InvestmentCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await investmentCommitteeImpl.address)}
  keyValues[15] = {"keyPrefix":"ADMIN", "keyName":"InvestmentManagementSetupAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await investmentManagementSetupAgentImpl.address)}
  keyValues[16] = {"keyPrefix":"ADMIN", "keyName":"InvestmentUCVManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await investmentUCVManagerImpl.address)}
  keyValues[17] = {"keyPrefix":"ADMIN", "keyName":"InvestmentUCV", "typeID":keccak256(toUtf8Bytes("address")), "data": (await investmentUCVImpl.address)}
  keyValues[18] = {"keyPrefix":"ADMIN", "keyName":"FundManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await fundManagerImpl.address)}
  keyValues[19] = {"keyPrefix":"ADMIN", "keyName":"InkFund", "typeID":keccak256(toUtf8Bytes("address")), "data": (await inkFundImpl.address)}
  

  await configManager.batchSetKV(admin, keyValues);

  console.log("deployed address ##################################################################################################################")
  console.log("config address:", configManager.address);
  console.log("factory address:", factoryManager.address);

}

deploy();