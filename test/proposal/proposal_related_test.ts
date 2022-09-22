
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { INK_CONFIG_DOMAIN, THE_TREASURY_MANAGER_AGENT_KEY, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
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

    it("test create treasury-setup proposal", async function () {
        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);        
        var erc20Address = inkERC20.address;

        // // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address);
        await factoryManager.deploy(DAOTypeID,MASTER_DAO_KEY,masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("dao address:", masterDAO.address);
        // // select one flow of the DAO

        var agents = []
        agents[0] = THE_TREASURY_MANAGER_AGENT_KEY;
        
        // agents[1] = toUtf8Bytes("");
        var headers = [];
        headers[0] = {
            "key":  "committeeKey",
            "typeID": THE_TREASURY_COMMITTEE_KEY,
            // "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": THE_TREASURY_COMMITTEE_KEY,
            "desc": "0x0002",
        };
        headers[1] = {
            "key":  "controllerAddress",
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
            "desc": "0x0002",
        };

        var kvData = [];
        kvData[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);

        // kvData[0] = {
        //     "key":  "key",
        //     "typeID": keccak256(toUtf8Bytes("typeID")),
        //     "data": "0x0001",
        //     "desc": "0x0002",
        // };


        var proposal = {
            "agents" : agents,
            "topicID" : keccak256(toUtf8Bytes("topic")),
            "crossChainProtocal":toUtf8Bytes(""),
            "metadata" : headers,
            "kvData" : kvData
        }

        // var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        
        var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        
        await theBoard.newProposal(proposal, true, "0x00");

        // var proposalID = await masterDAO.getProposalIDByIndex(0);
        // // console.log("first proposal id: ", proposalID);
        // await voteProposal(proposalID, flowSteps[1].step, flowSteps[1].committee);

        // // once decide, 
        // await tallyVotes(proposalID, flowSteps[1].step, flowSteps[1].committee);


    });

    /*
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
        
        // create agent
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
        console.log(flowSteps);
        console.log("first proposal committee:", flowSteps[0].committee);

        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        await theBoard.newProposal(proposal, true, "0x00");
        var proposalID = await masterDAO.getProposalIDByIndex(0);

        console.log("first proposal id: ", proposalID);
        
        await voteProposal(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await voteDetail(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await voteAccountInfo(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await tallyVotes(proposalID, flowSteps[1].step, flowSteps[1].committee);

    });
    */



    async function voteProposal (proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var thePublicCommitteeFactory = await ethers.getContractFactory("ThePublic");
        var thePublicCommittee = await thePublicCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};
        
        await thePublicCommittee.vote(voteIdentity, true, 10, "", "0x00");
    }


    async function voteDetail (proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var thePublicCommitteeFactory = await ethers.getContractFactory("ThePublic");
        var thePublicCommittee = await thePublicCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};


        console.log("vote detail info:", await thePublicCommittee.getVoteDetail(voteIdentity, true, "0x0000000000000000000000000000000000000000", 10));
    }


    async function voteAccountInfo (proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);

        var thePublicCommitteeFactory = await ethers.getContractFactory("ThePublic");
        var thePublicCommittee = await thePublicCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};
        const signers = await ethers.getSigners();
        console.log("getVoteDetailByAccount:", await thePublicCommittee.getVoteDetailByAccount(voteIdentity, await signers[0].address));
    }


    async function tallyVotes (proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var thePublicCommitteeFactory = await ethers.getContractFactory("ThePublic");
        var thePublicCommittee = await thePublicCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};
        
        await thePublicCommittee.tallyVotes(voteIdentity, "0x00");
        
    }


})