
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 

import { masterDAO_ContractID, theBoard_ContractID, thePublic_ContractID, treasuryCommittee_ContractID} from '../shared/fixtures'; 
import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { buildMasterDAOInitData } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';

// const {

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("contract dao test", function () {

    // it("test create master dao", async function () {

        // const {factoryManager} = await loadFixture(FactoryManagerFixture);
        // const {inkERC20} = await loadFixture(InkERC20Fixture);        
        // var erc20Address = inkERC20.address;
        // var stakingAddress = erc20Address;
        // var committees = [];


        // var theBoardCommitteeDutyIDs = PROPOSER_DUTYID;
        // var thePublicCommitteeDutyIDs = VOTER_DUTYID;


        // var proposalTuple = 'tuple(bytes32, string, uint256, bytes)';
        // committees[0] = [keccak256(toUtf8Bytes("generate proposal")), theBoard_ContractID, 1, theBoardCommitteeDutyIDs]; 
        // committees[1] = [keccak256(toUtf8Bytes("public vote")), thePublic_ContractID, 0, thePublicCommitteeDutyIDs];

        // var flows = [];
        // var flowTuple = 'tuple(bytes32, ' + proposalTuple +'[])';
        // // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[theBoard_ContractID, proposalCommittees]]);
        // flows[0] = [keccak256(toUtf8Bytes("0")), committees];



        // var mds = [];
        // mds[0] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content1"));
        // mds[1] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content2"));
        // mds[2] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content3"));

        // var badgeName = "badgeName1";
        // var badgeTotal = 100;
        // var daoLogo = "daoDefaultLogo";
        // var minPledgeRequired = 10;
        // var minEffectiveVotes = 100;
        // var minEffectiveVoteWallets = 1;

        // var masterDAOInitialData = defaultAbiCoder.encode(['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256, ' + flowTuple +'[])'],
        //      [["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets, flows]]);
        // await factoryManager.deploy(masterDAO_ContractID, masterDAOInitialData);
        // var firstDAOAddress = await factoryManager.getDeployedAddress(masterDAO_ContractID, 0);
        // var masterDAO = await ethers.getContractFactory("MasterDAO");
        // var contract = masterDAO.attach(firstDAOAddress);

        // console.log("first dao address:", contract.address);
        

    // });

    it("test create proposal", async function () {

        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);        
        var erc20Address = inkERC20.address;

        // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address);
        await factoryManager.deploy(masterDAO_ContractID, masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(masterDAO_ContractID, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("second dao address:", masterDAO.address);
        // select one flow of the DAO
        
        // create two agent first, the DAO agent
        /*
            Proposal calldata proposal,
            bool commit,
            bytes calldata data
        */
        var agents = []
        agents[0] = 0x0;
        
        // agents[1] = toUtf8Bytes("");
        var headers = [];
        headers[0] = {
            "key":  keccak256(toUtf8Bytes("key name")),
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": toUtf8Bytes("data"),
            "desc": toUtf8Bytes("desc")
        };

        var contents = [];
        contents[0] = {
            "key":  keccak256(toUtf8Bytes("key name")),
            "typeID": keccak256(toUtf8Bytes("typeID 原象")),
            "data": toUtf8Bytes("data"),
            "desc": toUtf8Bytes("desc")
        };
        var proposal = {
            "agents" : agents,
            "topicID" : keccak256(toUtf8Bytes("topic")),
            "crossChainProtocal":toUtf8Bytes(""),
            "headers" : headers,
            "contents" : contents
        }
        // await masterDAO.newProposal(proposal, true, toUtf8Bytes(""));
        
        // create a new flow
        // 全0 / 全F  




    
    });

})