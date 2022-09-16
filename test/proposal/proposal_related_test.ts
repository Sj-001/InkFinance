
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { INK_CONFIG_DOMAIN, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
import { FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID } from '../shared/fixtures'; 
import { buildMasterDAOInitData } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';

// const {

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("proposal related test", function () {


    it("test create off-chain proposal", async function () {

        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);        
        var erc20Address = inkERC20.address;

        // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address);
        await factoryManager.deploy(DAOTypeID,MASTER_DAO_KEY,masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("dao address:", masterDAO.address);
        // select one flow of the DAO
        
        // create two agent first, the DAO agent
        /*
            Proposal calldata proposal,
            bool commit,
            bytes calldata data
        */
        var agents = []
        agents[0] = "0x0000000000000000000000000000000000000000000000000000000000000000";
        
        // agents[1] = toUtf8Bytes("");
        var headers = [];
        headers[0] = {
            "key":  keccak256(toUtf8Bytes("key name")),
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": "0x0001",
            "desc": "0x0002",
        };

        var contents = [];
        contents[0] = {
            "key":  keccak256(toUtf8Bytes("key name")),
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": "0x0001",
            "desc": "0x0002",
        };
        var proposal = {
            "agents" : agents,
            "topicID" : keccak256(toUtf8Bytes("topic")),
            "crossChainProtocal":toUtf8Bytes(""),
            "headers" : headers,
            "contents" : contents
        }

        var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");

        console.log("first proposal committee:", flowSteps[0].committee);
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        await theBoard.newProposal(proposal, true, "0x00");
        


        // await masterDAO.newProposal(proposal, true, "0x0000000000000000000000000000000000000000000000000000000000000000");

    });




})