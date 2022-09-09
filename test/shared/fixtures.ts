
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { GlobalConfig } from '../../typechain/GlobalConfig'

import * as ConfigManagerABI from "../../artifacts/contracts/cores/ConfigManager.sol/ConfigManager.json";
import * as FactoryManagerABI from "../../artifacts/contracts/cores/FactoryManager.sol/FactoryManager.json";
import * as MasterDAOABI from "../../artifacts/contracts/daos/MasterDAO.sol/MasterDAO.json";
import * as InkERC20ABI from "../../artifacts/contracts/tokens/InkERC20.sol/InkERC20.json";
import * as TheBoardABI from "../../artifacts/contracts/committee/TheBoard.sol/TheBoard.json";
import * as ThePublicABI from "../../artifacts/contracts/committee/ThePUblic.sol/ThePublic.json";
import * as TreasuryCommitteeABI from "../../artifacts/contracts/committee/TreasuryCommittee.sol/TreasuryCommittee.json";

const {loadFixture, deployContract} = waffle;

// dutyID(Role)

/**
 * Contract IDs
 */
//masterDAO_ID = keccak256("MasterDAO_V2") = 0xaddf9e5a9a5a510452bc962afc0081e28cbdbefa6e1dea786693b83532ed9ac5;
//console.log("masterDAO_ID=", keccak256(toUtf8Bytes("MasterDAO_V2")));
const masterDAO_ContractID = "0xaddf9e5a9a5a510452bc962afc0081e28cbdbefa6e1dea786693b83532ed9ac5";

//console.log("TheBoard_ContractID=", keccak256(toUtf8Bytes("TheBoard_ContractID")));
const theBoard_ContractID = "0xf8a2320010c84262591b8cc8c943833c7c4a50c51e804d47b11be9d6c1e295eb";

//console.log("ThePublic_ContractID=", keccak256(toUtf8Bytes("ThePublic_ContractID")));
const thePublic_ContractID = "0xe08417244a758bb2b225a536c66324251783cd4813c248ab118043888bf576c8";

//console.log("TreasuryCommittee_ContractID=", keccak256(toUtf8Bytes("TreasuryCommittee_ContractID")));
const treasuryCommittee_ContractID = "0xa6c8d1a18e7f6ee65bf32a9844e0c6ac70c6235969a004f5a59b886f34d3563c";

/**
 * Ink Default DutyIDs
 */
//console.log("defaultProposer_DutyID=", keccak256(toUtf8Bytes("defaultProposer_DutyID")));
const defaultProposer_DutyID = "0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e";

export async function FactoryManagerFixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();
    const globalConfig = await deployContract(signers[0], ConfigManagerABI);
    await globalConfig.deployed();
    console.log("config address:", globalConfig.address);

    // await config.grantRole(BEACON_UPGRADER_ROLE, signers[0].address);
    // const config_addr =  await config.address;
    const factoryManager = await deployContract(signers[0], FactoryManagerABI, [globalConfig.address]);
    await factoryManager.deployed();

    const theBoardCommitteeImpl = await deployContract(signers[0], TheBoardABI, []);
    await theBoardCommitteeImpl.deployed();

    const thePublicCommitteeImpl = await deployContract(signers[0], ThePublicABI, []);
    await thePublicCommitteeImpl.deployed();

    const theTreasuryCommitteeImpl = await deployContract(signers[0], TreasuryCommitteeABI, []);
    await theTreasuryCommitteeImpl.deployed();

    // init project implementation
    let masterDAOImpl: Contract = await deployContract(signers[0], MasterDAOABI);
    await factoryManager.addContract(masterDAO_ContractID, masterDAOImpl.address);
    await factoryManager.addContract(theBoard_ContractID, theBoardCommitteeImpl.address);
    await factoryManager.addContract(thePublic_ContractID, thePublicCommitteeImpl.address);
    await factoryManager.addContract(treasuryCommittee_ContractID, theTreasuryCommitteeImpl.address);

    return {factoryManager};
}


export async function InkERC20Fixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();

    const inkERC20 = await deployContract(signers[0], InkERC20ABI, ["InkERC20", ""]);
    await inkERC20.deployed();

    return {inkERC20};
}


export {masterDAO_ContractID, theBoard_ContractID, thePublic_ContractID, treasuryCommittee_ContractID}
export {defaultProposer_DutyID}