
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'

import * as ConfigManagerABI from "../../artifacts/contracts/cores/ConfigManager.sol/ConfigManager.json";
import * as FactoryManagerABI from "../../artifacts/contracts/cores/FactoryManager.sol/FactoryManager.json";
import * as MasterDAOABI from "../../artifacts/contracts/daos/MasterDAO.sol/MasterDAO.json";
import * as InkERC20ABI from "../../artifacts/contracts/tokens/InkERC20.sol/InkERC20.json";
import * as TheBoardABI from "../../artifacts/contracts/committee/TheBoard.sol/TheBoard.json";
import * as ThePublicABI from "../../artifacts/contracts/committee/ThePUblic.sol/ThePublic.json";
import * as TreasuryCommitteeABI from "../../artifacts/contracts/committee/TreasuryCommittee.sol/TreasuryCommittee.json";
import * as TreasuryManagerAgentABI from "../../artifacts/contracts/agents/TreasuryManagerAgent.sol/TreasuryManagerAgent.json";
import * as PayrollExecuteAgentABI from "../../artifacts/contracts/agents/PayrollExecuteAgent.sol/PayrollExecuteAgent.json";
import * as PayrollSetupAgentABI from "../../artifacts/contracts/agents/PayrollSetupAgent.sol/PayrollSetupAgent.json";
import * as PayrollUCVManagerABI from "../../artifacts/contracts/ucv/PayrollUCVManager.sol/PayrollUCVManager.json";
import * as ProposalHandlerABI from "../../artifacts/contracts/proposal/ProposalHandler.sol/ProposalHandler.json";
import * as InkBadgeERC20ABI from "../../artifacts/contracts/tokens/InkBadgeERC20.sol/InkBadgeERC20.json";


import * as PayrollUCVABI from "../../artifacts/contracts/ucv/PayrollUCV.sol/PayrollUCV.json";
import * as IncomeManagerSetupAgentABI from "../../artifacts/contracts/agents/IncomeManagerSetupAgent.sol/IncomeManagerSetupAgent.json";
import * as TreasuryIncomeManagerABI from "../../artifacts/contracts/ucv/TreasuryIncomeManager.sol/TreasuryIncomeManager.json";


const {loadFixture, deployContract} = waffle;

// dutyID(Role)

console.log("FactoryTypeID=", keccak256(toUtf8Bytes("FactoryTypeID")));
const FactoryTypeID = "0x2ee16ad566e4eda6ce43d2dbc3246bc52bfd29238d275308f043f2b4d69117ab";
console.log("FactoryTypeID=", FactoryTypeID);

console.log("DAOTypeID=", keccak256(toUtf8Bytes("DAOTypeID")));
const DAOTypeID = "0xdeb63a88d4573ec3359155ef44dd570a22acdf5208f7256d196e6bb7483d1b85";
console.log("DAOTypeID=", DAOTypeID);

console.log("AgentTypeID=", keccak256(toUtf8Bytes("AgentTypeID")));
const AgentTypeID = "0x7d842b1d0bd0bab5012e5d26d716987eab6183361c63f15501d815f133f49845";
console.log("AgentTypeID=", AgentTypeID);

console.log("CommitteeTypeID=", keccak256(toUtf8Bytes("CommitteeTypeID")));
const CommitteeTypeID = "0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f";
console.log("CommitteeTypeID=", CommitteeTypeID);

console.log("UCVTypeID=", keccak256(toUtf8Bytes("UCVTypeID")));
const UCVTypeID = "0x7f16b5baf10ee29b9e7468e87c742159d5575c73984a100d194e812750cad820";
console.log("UCVTypeID=", UCVTypeID);

console.log("UCVManagerTypeID=", keccak256(toUtf8Bytes("UCVManagerTypeID")));
const UCVManagerTypeID = "0x9dbd9f87f8d58402d143fb49ec60ec5b8c4fa567e418b41a6249fd125a267101";
console.log("UCVManagerTypeID=", UCVTypeID);

console.log("PropoalHandlerTypeID=", keccak256(toUtf8Bytes("PropoalHandlerTypeID")));
const PropoalHandlerTypeID = "0x1858c200a95d03e2d42c3cf57541f3bc9a8c8471b5f80b7c26e756d34fbced97";
console.log("PropoalHandlerTypeID=", PropoalHandlerTypeID);

export {FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID}

// signer[0].address
const INK_CONFIG_DOMAIN = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
// domain + prefix + keyName
// INK_CONFIG_DOMAIN + "ADMIN" + "FactoryManager"
const FACTORY_MANAGER_KEY = "0x618e90bb05c847d0be7158fb3420e6f74c0a99195db496d41aec554825d43862";
console.log("FACTORY_MANAGER_KEY=", FACTORY_MANAGER_KEY);

const THE_BOARD_COMMITTEE_KEY = "0x9386c0f239c958604010fb0d19f447c347da25b93a863f07e6c4a1a5eca03672";
console.log("THE_BOARD_COMMITTEE_KEY=", THE_BOARD_COMMITTEE_KEY);

const THE_PUBLIC_COMMITTEE_KEY = "0x83dcde2860892c57c8131e2c92e51a080b3487f90ce3a4e0ee4b54147edce466";
console.log("THE_PUBLIC_COMMITTEE_KEY=", THE_PUBLIC_COMMITTEE_KEY);

const MASTER_DAO_KEY = "0xc12854b9da098afcfaccab376a8e09d5d552c45f82f6a53907068941a57206d0";
console.log("MASTER_DAO_KEY=", MASTER_DAO_KEY);

const THE_TREASURY_COMMITTEE_KEY = "0xb3ad0198e4ec4a0db963333524464a188289da1a5691c67d47c2364c09817df0";
console.log("THE_TREASURY_COMMITTEE_KEY=", THE_TREASURY_COMMITTEE_KEY);

const THE_TREASURY_MANAGER_AGENT_KEY = "0x01daab39d6af5b8f8de2237107ebffcbfba7ecbcac254fd429eb4543f0a2bf4a";
console.log("THE_TREASURY_MANAGER_AGENT_KEY=", THE_TREASURY_MANAGER_AGENT_KEY);

const PAYROLL_UCV_KEY = "0x1884db1d28ee07f8a363b415d044ce8a3e387ece0b603ebd0df3c4cc133ef70a";
console.log("PAYROLL_UCV_KEY=", PAYROLL_UCV_KEY);

const PAYROLL_SETUP_AGENT_KEY = "0xe5a30123c30286e56f6ea569f1ac6b59ea461ceabf0b46dfb50c7eadb91c28c1";
console.log("PAYROLL_SETUP_AGENT_KEY=", PAYROLL_SETUP_AGENT_KEY);

const PAYROLL_EXECUTE_AGENT_KEY = "0xce8413630ab56be005a97f0ae8be1835fb972819fa4327995eb9568c76252d28";
console.log("PAYROLL_EXECUTE_AGENT_KEY=", PAYROLL_EXECUTE_AGENT_KEY);

const PAYROLL_UCV_MANAGER_KEY = "0x8856ac0b66da455dc361f170f91264627f70b6333b9103ff6104df3ce47aa4ec";
console.log("PAYROLL_UCV_MANAGER_KEY=", PAYROLL_UCV_MANAGER_KEY);

const PROPOSAL_HANDLER_KEY = "0xb2398891ec8f5bab18552ac978b2f975052c12e4d8f0a942c7154ba6e0758e5f";
console.log("PROPOSAL_HANDLER_KEY=", PROPOSAL_HANDLER_KEY);

const INCOME_MANAGER_SETUP_AGENT_KEY = "0xcec8d2431799add509550588e4952385367c7958a96a6b2da6f930e3a92d5bb0";
console.log("INCOME_MANAGER_SETUP_AGENT_KEY=", INCOME_MANAGER_SETUP_AGENT_KEY);

const TREASURY_INCOME_MANAGER_KEY = "0x86fec7bdac1c666265086eb15fc9444c124badd56d9bac9524f254189e56a632";
console.log("TREASURY_INCOME_MANAGER_KEY=", TREASURY_INCOME_MANAGER_KEY);


const INK_BADGE_KEY = "0x13515aecc01c430c059366623341389d823cb17a03398215f194736dadafb430";
console.log("INK_BADGE_KEY=", INK_BADGE_KEY);

export {INK_BADGE_KEY, INCOME_MANAGER_SETUP_AGENT_KEY, TREASURY_INCOME_MANAGER_KEY, PROPOSAL_HANDLER_KEY, PAYROLL_UCV_KEY, PAYROLL_UCV_MANAGER_KEY, PAYROLL_EXECUTE_AGENT_KEY, PAYROLL_SETUP_AGENT_KEY, INK_CONFIG_DOMAIN, THE_TREASURY_MANAGER_AGENT_KEY, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY}

/**
 * Ink Default DutyIDs
 */
console.log("PROPOSER_DUTYID=", keccak256(toUtf8Bytes("dutyID.PROPOSER")));
const PROPOSER_DUTYID = "0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e";

console.log("VOTER_DUTYID=", keccak256(toUtf8Bytes("dutyID.VOTER")));
const VOTER_DUTYID = "0xf579da1548edf1a4b47140c7e8df0e1e9f881c48184756b7f660e33bbc767607";

console.log("OPERATOR_DUTYID=", keccak256(toUtf8Bytes("dutyID.OPERATOR")));
const OPERATOR_DUTYID = "0x7fc29d7165e16fd9e059fc2637218a216a838baf76410a896bd9789802186cd4";

console.log("SIGNER_DUTYID=", keccak256(toUtf8Bytes("dutyID.SIGNER")));
const SIGNER_DUTYID = "0x461cab96cf4e8d93f044537dc0accaa1fa44a556bed2df44eb88ea471c2c186f";

console.log("AUDITOR_DUTYID=", keccak256(toUtf8Bytes("dutyID.AUDITOR")));
const AUDITOR_DUTYID = "0x7f014c5b03a1a6fcf5a57ebc1689669c0315c27f4755c182dbd0f35a51a754eb";

console.log("TREASURY_PAYROLL_SETUP_DUTYID=", keccak256(toUtf8Bytes("dutyID.TREASURY_PAYROLL_SETUP")));
const TREASURY_PAYROLL_SETUP_DUTYID = "0xf579da1548edf1a4b47140c7e8df0e1e9f881c48184756b7f660e33bbc767607";


export async function FactoryManagerFixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();
    const configManager = await deployContract(signers[0], ConfigManagerABI);
    await configManager.deployed();
    console.log("config address:", configManager.address);
    console.log("ink config domain(deployer's address):", signers[0].address);

    // await config.grantRole(BEACON_UPGRADER_ROLE, signers[0].address);
    // const config_addr = await config.address;
    const factoryManager = await deployContract(signers[0], FactoryManagerABI, [configManager.address]);
    await factoryManager.deployed();

    console.log("factory address:", await factoryManager.address);

    const theBoardCommitteeImpl = await deployContract(signers[0], TheBoardABI, []);
    await theBoardCommitteeImpl.deployed();
    console.log("TheBoardCommittee Address=", theBoardCommitteeImpl.address);

    const thePublicCommitteeImpl = await deployContract(signers[0], ThePublicABI, []);
    await thePublicCommitteeImpl.deployed();
    console.log("PublicCommittee Address=", thePublicCommitteeImpl.address);

    const theTreasuryCommitteeImpl = await deployContract(signers[0], TreasuryCommitteeABI, []);
    await theTreasuryCommitteeImpl.deployed();
    console.log("TreasuryCommittee Address=", theTreasuryCommitteeImpl.address);

    const theTreasuryManagerAgentImpl = await deployContract(signers[0], TreasuryManagerAgentABI, []);
    await theTreasuryManagerAgentImpl.deployed();
    console.log("TreasuryManagerAgent Address=", theTreasuryManagerAgentImpl.address);

    // init project implementation
    let masterDAOImpl: Contract = await deployContract(signers[0], MasterDAOABI);
    await masterDAOImpl.deployed();

    
    const payrollSetupAgentImpl = await deployContract(signers[0], PayrollSetupAgentABI, []);
    await payrollSetupAgentImpl.deployed();
    console.log("PayrollSetupAgent Address=", payrollSetupAgentImpl.address);

    const payrollExecuteAgentImpl = await deployContract(signers[0], PayrollExecuteAgentABI, []);
    await payrollExecuteAgentImpl.deployed();
    console.log("PayrollExecuteAgent Address=", payrollExecuteAgentImpl.address);


    const payrollUCVManagerImpl = await deployContract(signers[0], PayrollUCVManagerABI, []);
    await payrollUCVManagerImpl.deployed();
    console.log("Payroll UCV Manager Address=", payrollUCVManagerImpl.address);

    const payrollUCVImpl = await deployContract(signers[0], PayrollUCVABI, []);
    await payrollUCVImpl.deployed();
    console.log("PayrollUCV Address=", payrollUCVImpl.address);

    const proposalHandlerImpl = await deployContract(signers[0], ProposalHandlerABI, []);
    await proposalHandlerImpl.deployed();
    console.log("ProposalHandler Address=", proposalHandlerImpl.address);

    const incomeManagerSetupAgentImpl = await deployContract(signers[0], IncomeManagerSetupAgentABI, []);
    await incomeManagerSetupAgentImpl.deployed();
    console.log("IncomeManagerSetupAgent Address=", incomeManagerSetupAgentImpl.address);

    const treasuryIncomeManagerImpl = await deployContract(signers[0], TreasuryIncomeManagerABI, []);
    await treasuryIncomeManagerImpl.deployed();
    console.log("treasuryIncomeManager Address=", treasuryIncomeManagerImpl.address);


    const inkBadgeKeyImpl = await deployContract(signers[0], InkBadgeERC20ABI, []);
    await inkBadgeKeyImpl.deployed();
    console.log("inkBadgeKeyImpl Address=", inkBadgeKeyImpl.address);

    console.log("init keys:");

    var factoryManagerFactoryKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "FactoryManager");
    console.log("factoryManagerFactoryKey=", factoryManagerFactoryKey);

    var masterDAOKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "MasterDAO");
    console.log("masterDAOKey=", masterDAOKey);

    var theBoardCommitteeKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "TheBoardCommittee");
    console.log("theBoardCommitteeKey=", theBoardCommitteeKey);

    var thePublicCommitteeKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "ThePublicCommittee");
    console.log("thePublicCommitteeKey=", thePublicCommitteeKey);

    var treasuryCommitteeKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "TreasuryCommittee");
    console.log("treasuryCommitteeKey=", treasuryCommitteeKey);

    var treasuryManagerAgentKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "TreasuryManagerAgent");
    console.log("treasuryManagerAgentKey=", treasuryManagerAgentKey);

    var payrollUCVKey = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "PayrollUCV");
    console.log("payrollUCVKey=", payrollUCVKey);

    var payrollSetupAgent = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "PayrollSetupAgent");
    console.log("payrollSetupAgentKey=", payrollSetupAgent);

    var payrollExecuteAgent = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "PayrollExecuteAgent");
    console.log("payrollExecuteAgentKey=", payrollExecuteAgent);

    var payrollUCVManager = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "PayrollUCVManager");
    console.log("payrollUCVManagerKey=", payrollUCVManager);

    var proposalHandler = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "ProposalHandler");
    console.log("ProposalHandlerKey=", proposalHandler);
 
    var incomeManagerSetupAgent = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "IncomeManagerSetupAgent");
    console.log("IncomeManagerSetupAgentKey=", incomeManagerSetupAgent);

    var treasuryIncomeManager = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "TreasuryIncomeManager");
    console.log("TreasuryIncomeManagerKey=", treasuryIncomeManager);

    var inkBadgeERC20Key = await configManager.buildConfigKey(INK_CONFIG_DOMAIN, "ADMIN", "InkBadgeERC20");
    console.log("inkBadgeERC20Key=", inkBadgeERC20Key);

    var keyValues = [];
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
    keyValues[13] = {"keyPrefix":"ADMIN", "keyName":"InkBadgeERC20", "typeID":keccak256(toUtf8Bytes("address")), "data": (await inkBadgeKeyImpl.address)}
    
    await configManager.batchSetKV(INK_CONFIG_DOMAIN, keyValues);

    console.log("config address and key:", await configManager.address, "|", FACTORY_MANAGER_KEY);
    console.log("factory manager key value:", await configManager.getKV(FACTORY_MANAGER_KEY));

    return {factoryManager};

}


export async function InkERC20Fixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();
    const inkERC20 = await deployContract(signers[0], InkERC20ABI, []);
    await inkERC20.init("InkERC20", "InkERC20")
    await inkERC20.deployed();

    return {inkERC20};
}


export async function ConfigManagerFixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();
    const configManager = await deployContract(signers[0], ConfigManagerABI, []);
    await configManager.deployed();

    return {configManager};
}

export {PROPOSER_DUTYID, VOTER_DUTYID}
