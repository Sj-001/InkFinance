
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture, KYCVerifyFixture } from '../shared/fixtures'; 

import { PROPOSAL_HANDLER_KEY,INK_CONFIG_DOMAIN, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
import { FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { buildMasterDAOInitData } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';
import { expect } from "chai";

// const {
    0x7a6e62f9b175c6a7be488b61998eee23ec460b880db24cfaf2109f3cf292c8b3

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("contract dao test", function () {
  

    it("test create master dao", async function () {

        const signers = await ethers.getSigners();

        const {factoryManager} = await FactoryManagerFixture();
        const {inkERC20} = await InkERC20Fixture();        
        var erc20Address = inkERC20.address;
        console.log("working 1")
        // select/create a DAO
        const {verifier} = await KYCVerifyFixture();        
        console.log("working 2")
        var identity = await verifier.getIdentityManager();
       
        // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address, 0, identity);
        var tx =  await factoryManager.deploy(true, DAOTypeID, MASTER_DAO_KEY,masterDAOInitialData);
        await tx.wait()
        console.log("working 3")
        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("working 4")
        console.log("first dao address:", masterDAO.address);
        
        console.log("committee infos:", await masterDAO.getDAOCommittees());

        
    });

})