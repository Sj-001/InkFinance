
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
import { buildMasterDAOInitData, buildOffchainProposal, buildPayrollPayProposal, buildPayrollSetupProposal, buildTreasurySetupProposal } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';

// const {

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("proposal related test", function () {

    it("test create treasury-setup proposal", async function () {

        const signers = await ethers.getSigners();
        console.log("########################current signer:", signers[0].address);
        
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

        var proposal = buildTreasurySetupProposal();

        // var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        
        var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        
        await theBoard.newProposal(proposal, true, "0x00");

        var proposalID = await masterDAO.getProposalIDByIndex(0);
        // console.log("first proposal id: ", proposalID);
        await voteProposal(proposalID, flowSteps[1].step, flowSteps[1].committee);

        // once decide, 
        await tallyVotes(proposalID, flowSteps[1].step, flowSteps[1].committee);
        
        var committeeAddress = await factoryManager.getDeployedAddress(THE_TREASURY_COMMITTEE_KEY,0);

        console.log("treasury committee amount:", await factoryManager.getDeployedAddressCount(THE_TREASURY_COMMITTEE_KEY));
        console.log("treasury committee address:", committeeAddress);
        
        // proposal category = payroll?
        await makeSetupPayrollProposal(committeeAddress, erc20Address);

        var payrollSetupProposalID = await masterDAO.getProposalIDByIndex(1);
        console.log(payrollSetupProposalID)

        var payrollTopicID = await masterDAO.getProposalTopic(payrollSetupProposalID);
        console.log("payroll proposal topic:: ", payrollTopicID);
        await makePayrollPayProposal(payrollTopicID, committeeAddress);

        var payrollProposalID = await masterDAO.getProposalIDByIndex(2);
        console.log("payroll proposal id: ", payrollProposalID);

        var payrollProposalSummary = await masterDAO.getProposalSummary(payrollProposalID);
        console.log("payroll proposal status:: ", payrollProposalSummary.status);


        var payrollVoteSteps = await masterDAO.getFlowSteps("0x4dd2d7e10785fafbaaf1f3990a197abc75ee660a97f6667083816f872ef1f877");

        await makePayrollPayProposal(payrollTopicID, committeeAddress);


    });

    async function makeSetupPayrollProposal (committeeAddress:string, erc20Address:string ) {
        // treasury committee has been setup.
        // now prepare to setup payroll
        console.log("financial-payroll-setup: ", keccak256(toUtf8Bytes("financial-payroll-setup")))
        
        var setupPayrollProposal = buildPayrollSetupProposal(erc20Address);

        var treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");

        var treasuryCommittee = treasuryCommitteeFactory.attach(committeeAddress);
        
        // pass direct
        await treasuryCommittee.newProposal(setupPayrollProposal, true, toUtf8Bytes(""));

    }

    async function makePayrollPayProposal (topicID:string, committeeAddress:string ) {
        // treasury committee has been setup.
        // now prepare to setup payroll

        var payrollPayProposal = buildPayrollPayProposal(topicID);

        var treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");

        var treasuryCommittee = treasuryCommitteeFactory.attach(committeeAddress);
        
        



        // make proposal and require voteing
        await treasuryCommittee.newProposal(payrollPayProposal, true, toUtf8Bytes(""));
        
    }

    
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
        
        var offchainProposal = buildOffchainProposal();

        var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        console.log(flowSteps);
        console.log("first proposal committee:", flowSteps[0].committee);

        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);




        await theBoard.newProposal(offchainProposal, true, "0x00");
        var proposalID = await masterDAO.getProposalIDByIndex(0);

        console.log("first proposal id: ", proposalID);
        
        await voteProposal(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await voteDetail(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await voteAccountInfo(proposalID, flowSteps[1].step, flowSteps[1].committee);

        await tallyVotes(proposalID, flowSteps[1].step, flowSteps[1].committee);

    });
    

    */

    async function votePayrollScheduleSignProposal (proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var theTreasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
        var thePublicCommittee = await theTreasuryCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};
        
        await thePublicCommittee.vote(voteIdentity, true, 10, "", "0x00");
    }


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