
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

const {loadFixture, deployContract} = waffle;



//factoryID = keccak256("EvolveDAO_V1") = 0x60eec8b3f99438edc77c51d2b840d1f89c11392cdfc43d32a97863378359cbba;
const factoryID = "0x60eec8b3f99438edc77c51d2b840d1f89c11392cdfc43d32a97863378359cbba";

export async function DeployerFixture(_wallets: Wallet[], _mockProvider: MockProvider) {
    const signers = await ethers.getSigners();


    const globalConfig = await deployContract(signers[0], GlobalConfigABI);
    await globalConfig.deployed();
    console.log("config address:", globalConfig.address);

    // await config.grantRole(BEACON_UPGRADER_ROLE, signers[0].address);
    // const config_addr =  await config.address;
    const factoryManager = await deployContract(signers[0], FactoryManagerABI);
    await factoryManager.deployed();

    // init project implementation
    let masterDAOImpl: Contract = await deployContract(signers[0], MasterDAOABI);
    await factoryManager.addContract(factoryID, masterDAOImpl.address);


    return {factoryManager};
}