
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 

import { masterDAO_ContractID, theBoard_ContractID, thePublic_ContractID, treasuryCommittee_ContractID} from '../shared/fixtures'; 
import { defaultProposer_DutyID } from '../shared/fixtures'; 
import { buildMasterDAOInitData } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';

// const {

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("contract dao test", function () {

    it("test create master dao", async function () {

        // const {factoryManager} = await loadFixture(FactoryManagerFixture);
        // const {inkERC20} = await loadFixture(InkERC20Fixture);        
        // var erc20Address = inkERC20.address;
        // var stakingAddress = erc20Address;
        // var proposalCommittees = [];
        // var proposalTuple = 'tuple(bytes32, string, uint256)';
        // proposalCommittees[0] = [keccak256(toUtf8Bytes("generate proposal")), theBoard_ContractID, 1]; 
        // proposalCommittees[1] = [keccak256(toUtf8Bytes("public vote")), thePublic_ContractID, 1];

        // var flows = [];
        // var flowTuple = 'tuple(bytes32, ' + proposalTuple +'[])';
        // // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[theBoard_ContractID, proposalCommittees]]);
        // flows[0] = [theBoard_ContractID, proposalCommittees];
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
        

    });

    it("test create proposal", async function () {

        // const {factoryManager} = await loadFixture(FactoryManagerFixture);
        // const {inkERC20} = await loadFixture(InkERC20Fixture);        
        // var erc20Address = inkERC20.address;

        // // select/create a DAO
        // var masterDAOInitialData = buildMasterDAOInitData(erc20Address);
        // await factoryManager.deploy(masterDAO_ContractID, masterDAOInitialData);

        // var firstDAOAddress = await factoryManager.getDeployedAddress(masterDAO_ContractID, 0);
        // var masterDAO = await ethers.getContractFactory("MasterDAO");
        // var contract = masterDAO.attach(firstDAOAddress);
        // console.log("second dao address:", contract.address);
        // select one flow of the DAO


        // create a new flow
        // 全0 / 全F



    
    });

})