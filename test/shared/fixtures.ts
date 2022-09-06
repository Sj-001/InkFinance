
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { GlobalConfig } from '../../typechain/GlobalConfig'

import * as GlobalConfigABI from "../../artifacts/contracts/cores/GlobalConfig.sol/GlobalConfig.json";
import * as FactoryManagerABI from "../../artifacts/contracts/cores/FactoryManager.sol/FactoryManager.json";
import * as MasterDAOABI from "../../artifacts/contracts/daos/MasterDAO.sol/MasterDAO.json";
import * as InkERC20ABI from "../../artifacts/contracts/tokens/InkERC20.sol/InkERC20.json";

const {loadFixture, deployContract} = waffle;

// dutyID(Role)



/**
 * Contract IDs
 */
//masterDAO_ID = keccak256("MasterDAO_V2") = 0xaddf9e5a9a5a510452bc962afc0081e28cbdbefa6e1dea786693b83532ed9ac5;
//console.log("masterDAO_ID=", keccak256(toUtf8Bytes("MasterDAO_V2")));
const masterDAO_ContractID = "0xaddf9e5a9a5a510452bc962afc0081e28cbdbefa6e1dea786693b83532ed9ac5";

/**
 * Ink Default DutyIDs
 */
//console.log("defaultProposer_DutyID=", keccak256(toUtf8Bytes("defaultProposer_DutyID")));
const defaultProposer_DutyID = "0x9afdbb55ddad3caca5623549b679d24148f7f60fec3d2cfc768e32e5f012096e";




export async function FactoryManagerFixture(_wallets: Wallet[], _mockProvider: MockProvider) {
    const signers = await ethers.getSigners();

    
    const globalConfig = await deployContract(signers[0], GlobalConfigABI);
    await globalConfig.deployed();
    console.log("config address:", globalConfig.address);

    // await config.grantRole(BEACON_UPGRADER_ROLE, signers[0].address);
    // const config_addr =  await config.address;
    const factoryManager = await deployContract(signers[0], FactoryManagerABI, [globalConfig.address]);
    await factoryManager.deployed();

    // init project implementation
    let masterDAOImpl: Contract = await deployContract(signers[0], MasterDAOABI);
    await factoryManager.addContract(masterDAO_ContractID, masterDAOImpl.address);


    return {factoryManager};
}


export async function InkERC20Fixture(_wallets: Wallet[], _mockProvider: MockProvider) {

    const signers = await ethers.getSigners();

    const inkERC20 = await deployContract(signers[0], InkERC20ABI, ["InkERC20", ""]);
    await inkERC20.deployed();

    return {inkERC20};
}


export {masterDAO_ContractID}
export {defaultProposer_DutyID}