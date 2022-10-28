
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
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address, 2);
        await factoryManager.deploy(true, DAOTypeID,MASTER_DAO_KEY,masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("dao address:", masterDAO.address);
        // // select one flow of the DAO

        var proposal = buildTreasurySetupProposal(signers[0].address, signers[0].address, signers[0].address);

        // var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        
        var theBoardAddress = await masterDAO.getDeployedContractByKey("0x9386c0f239c958604010fb0d19f447c347da25b93a863f07e6c4a1a5eca03672");
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        // var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        var theBoard = theBoardFactory.attach(theBoardAddress);

        await theBoard.newProposal(proposal, true, "0x00");

        
        console.log("committee infos:", await masterDAO.getDAOCommittees());

        var proposalID = await masterDAO.getProposalIDByIndex(0);
    
        console.log("first proposal id: ", proposalID);
        await voteProposalByThePublic(await masterDAO.address, proposalID);

        // once decide, 
        await tallyVotesByThePublic(await masterDAO.address,  proposalID);
        
        var committeeAddress = await masterDAO.getDeployedContractByKey(THE_TREASURY_COMMITTEE_KEY);

        console.log("treasury committee:", committeeAddress);

        console.log("dao committees: ", await masterDAO.getDAOCommittees());


        var treasurySetupProposalID = await masterDAO.getProposalIDByIndex(0);
        console.log("treasury setup proposal", treasurySetupProposalID)


        var treasurySetupPropoalTopicID = await masterDAO.getProposalTopic(treasurySetupProposalID);
        console.log("treasury setup proposal topic:: ", treasurySetupPropoalTopicID);

        // proposal category = payroll?
        await makeSetupPayrollProposal(committeeAddress, erc20Address, treasurySetupPropoalTopicID);


        var payrollSetupProposalID = await masterDAO.getProposalIDByIndex(1);
        console.log("payroll setup proposal", payrollSetupProposalID)

    
        var payrollSetupPropoalTopicID = await masterDAO.getProposalTopic(payrollSetupProposalID);
        console.log("treasury setup proposal topic:: ", payrollSetupPropoalTopicID);

        await votePayrollSetupProposal(payrollSetupProposalID, keccak256(toUtf8Bytes("generate payroll setup")), committeeAddress)

        var payManager = await masterDAO.getUCVManagers();
        console.log("ucv managers: ", await payManager);
        

        var payrollUCVManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var payrollUCVManager = await payrollUCVManagerFactory.attach(payManager[0]);


        await makePayrollPayProposal(payrollSetupPropoalTopicID, committeeAddress, payManager[0]);

        var payrollProposalID = await masterDAO.getProposalIDByIndex(2);
        console.log("payroll proposal id: ", payrollProposalID);

        
        var payrollProposalSummary = await masterDAO.getProposalSummary(payrollProposalID);
        console.log("payroll proposal status:: ", payrollProposalSummary.status);
        


    });

    async function makeSetupPayrollProposal (committeeAddress:string, erc20Address:string , topicID:string) {
        // treasury committee has been setup.
        // now prepare to setup payroll
        console.log("financial-payroll-setup: ", keccak256(toUtf8Bytes("financial-payroll-setup")))
        
        var setupPayrollProposal = buildPayrollSetupProposal(erc20Address, topicID);

        var treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");

        var treasuryCommittee = treasuryCommitteeFactory.attach(committeeAddress);
        
        // pass direct
        await treasuryCommittee.newProposal(setupPayrollProposal, true, toUtf8Bytes(""));

        

    }

    async function makePayrollPayProposal (topicID:string, committeeAddress:string, managerAddress:string ) {
        // treasury committee has been setup.
        // now prepare to setup payroll

        var payrollPayProposal = buildPayrollPayProposal(topicID, managerAddress);

        var treasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");

        var treasuryCommittee = treasuryCommitteeFactory.attach(committeeAddress);
        
        // make proposal and require voteing
        await treasuryCommittee.newProposal(payrollPayProposal, true, toUtf8Bytes(""));        
    }

    

    
    async function votePayrollSetupProposal ( proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var theTreasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
        var theTreasuryCommittee = await theTreasuryCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};
        
        await theTreasuryCommittee.vote(voteIdentity, true, 10, "", "0x00");
    }


    

    async function votePayrollScheduleSignProposal ( proposalID:string, step:string, committeeAddress:string ) {
        
        console.log("proposalID", proposalID);
        console.log("committeeAddress", committeeAddress);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var theTreasuryCommitteeFactory = await ethers.getContractFactory("TreasuryCommittee");
        var theCommittee = await theTreasuryCommitteeFactory.attach(committeeAddress);
        var voteIdentity = {"proposalID":proposalID, "step":step};

        await theCommittee.vote(voteIdentity, true, 10, "", "0x00");
    }


    async function voteProposalByThePublic(daoAddress:string, proposalID:string) {
        
        console.log("voteProposalByThePublic proposalID", proposalID);

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);
        console.log("voteProposalByThePublic vote committee info:", await committeeInfo);
        // var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        // var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);
        const theVoteCommittee = await ethers.getContractAt("ICommittee", committeeInfo.committee);
        var voteIdentity = {"proposalID":proposalID, "step": committeeInfo.step};
        
        await theVoteCommittee.vote(voteIdentity, true, 10, "", "0x00");

    }

    async function voteProposalByTheBoard(daoAddress:string, proposalID:string) {
        
        console.log("voteProposalByTheBoard proposalID", proposalID);

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);
        console.log("voteProposalByTheBoard vote committee info:", await committeeInfo);
        // var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        // var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);
        const theVoteCommittee = await ethers.getContractAt("ICommittee", committeeInfo.committee);
        var voteIdentity = {"proposalID":proposalID, "step": committeeInfo.step};
        
        await theVoteCommittee.vote(voteIdentity, true, 10, "", "0x00");

    }


    async function voteDetail (daoAddress:string, proposalID:string ) {
        
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);

        var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);

        console.log("vote detail the vote committee :", committeeInfo);
        var voteIdentity = {"proposalID":proposalID, "step":committeeInfo.step};


        console.log("vote detail info:", await theVoteCommittee.getVoteDetail(voteIdentity, true, "0x0000000000000000000000000000000000000000", 10));
    }


    async function voteAccountInfo (daoAddress:string, proposalID:string ) {
        
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);

        var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);

        console.log("vote detail the vote committee :", committeeInfo);
        var voteIdentity = {"proposalID":proposalID, "step":committeeInfo.step};



        const signers = await ethers.getSigners();
        console.log("getVoteDetailByAccount:", await theVoteCommittee.getVoteDetailByAccount(voteIdentity, await signers[0].address));
    }


    async function tallyVotesByThePublic (daoAddress:string, proposalID:string ) {

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);

        var theVoteCommitteeFactory = await ethers.getContractFactory("ThePublic");
        var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);

        console.log("vote detail the vote committee :", committeeInfo);
        var voteIdentity = {"proposalID":proposalID, "step":committeeInfo.step};
        
        await theVoteCommittee.tallyVotes(voteIdentity, "0x00");
        
    }


})