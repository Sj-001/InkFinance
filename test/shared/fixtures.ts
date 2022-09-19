
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
import * as DefaultAgentABI from "../../artifacts/contracts/agents/DefaultAgent.sol/DefaultAgent.json";
import * as TreasuryManagerAgentABI from "../../artifacts/contracts/agents/TreasuryManagerAgent.sol/TreasuryManagerAgent.json";


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

export {INK_CONFIG_DOMAIN, THE_TREASURY_MANAGER_AGENT_KEY, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY}

/**
 * Ink Default DutyIDs
 */
console.log("PROPOSER_DUTYID=", keccak256(toUtf8Bytes("PROPOSER_DUTYID")));
const PROPOSER_DUTYID = "0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e";

console.log("VOTER_DUTYID=", keccak256(toUtf8Bytes("VOTER_DUTYID")));
const VOTER_DUTYID = "0xf579da1548edf1a4b47140c7e8df0e1e9f881c48184756b7f660e33bbc767607";

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

    const defaultAgentImpl = await deployContract(signers[0], DefaultAgentABI, []);
    await defaultAgentImpl.deployed();

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


    var keyValues = [];
    keyValues[0] = {"keyPrefix":"ADMIN", "keyName":"FactoryManager", "typeID":keccak256(toUtf8Bytes("address")), "data": (await factoryManager.address)}
    keyValues[1] = {"keyPrefix":"ADMIN", "keyName":"TheBoardCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theBoardCommitteeImpl.address)}
    keyValues[2] = {"keyPrefix":"ADMIN", "keyName":"ThePublicCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await thePublicCommitteeImpl.address)}
    keyValues[3] = {"keyPrefix":"ADMIN", "keyName":"TreasuryCommittee", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theTreasuryCommitteeImpl.address)}
    keyValues[4] = {"keyPrefix":"ADMIN", "keyName":"MasterDAO", "typeID":keccak256(toUtf8Bytes("address")), "data": (await masterDAOImpl.address)}
    keyValues[5] = {"keyPrefix":"ADMIN", "keyName":"TreasuryManagerAgent", "typeID":keccak256(toUtf8Bytes("address")), "data": (await theTreasuryManagerAgentImpl.address)}
 

    await configManager.batchSetKV(INK_CONFIG_DOMAIN, keyValues);

    console.log("config address and key:", await configManager.address, "|", FACTORY_MANAGER_KEY);    
    console.log("factory manager key value:", await configManager.getKV(FACTORY_MANAGER_KEY));

    return {factoryManager};
}


export async function InkERC20Fixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();
    const inkERC20 = await deployContract(signers[0], InkERC20ABI, ["InkERC20", ""]);
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
