
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture, PAYROLL_UCV_MANAGER_KEY } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { INK_CONFIG_DOMAIN, THE_TREASURY_MANAGER_AGENT_KEY, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
import { FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID } from '../shared/fixtures'; 
import { buildPayees, buildMasterDAOInitData, buildOffchainProposal, buildPayrollPayProposal, buildPayrollSetupProposal, buildTreasurySetupProposal } from '../shared/parameters'; 


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
        
        var theBoardAddress = await masterDAO.getDeployedContractByKey(THE_BOARD_COMMITTEE_KEY);

        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        // var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        var theBoard = theBoardFactory.attach(theBoardAddress);

        await theBoard.newProposal(proposal, true, "0x00");

        var proposalID = await masterDAO.getProposalIDByIndex(0);
        
        // // console.log("first proposal id: ", proposalID);
        await voteProposalByThePublic(await masterDAO.address, proposalID);

        // // once decide, 
        await tallyVotes(await masterDAO.address, proposalID);
        

        // var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);
        // var theVoteCommittee = await theBoard.attach(committeeInfo.committee);

        console.log("proposal detail the vote committee :", await masterDAO.getProposalSummary(proposalID));
        // var voteIdentity = {"proposalID":proposalID, "step":committeeInfo.step};

        // console.log("vote detail info:", await theVoteCommittee.getVoteDetail(voteIdentity, true, "0x0000000000000000000000000000000000000000", 10));


        var committeeAddress = await factoryManager.getDeployedAddress(THE_TREASURY_COMMITTEE_KEY,0);

        // console.log("treasury committee amount:", await factoryManager.getDeployedAddressCount(THE_TREASURY_COMMITTEE_KEY));
        console.log("treasury committee address:", committeeAddress);
        
        await setupPayroll(masterDAO.address, erc20Address);

        await signPayroll(masterDAO.address, erc20Address);

        await claimPayroll(masterDAO.address, erc20Address);
        

    });

    async function claimPayroll(daoAddress:string, token:string) {
        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        

        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);

        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);

        
        console.log("check how many token could claim: ", await ucvManager.getClaimableAmount(1, signers[0].address));
    }


    async function signPayroll(daoAddress:string, token:string) {
        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        

        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);

        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);

        await ucvManager.signPayID(1, 1);
        console.log("check is signed: ", await ucvManager.isPayIDSigned(1,1));
    }


    async function setupPayroll(daoAddress:string, token:string) {
        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        

        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);

        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);
        var timestamp = Date.now();
        var sec = Math.floor(timestamp / 1000);

        var startTime = sec - 60 * 60 * 24;
        var period = 60 * 60;
        var payTimes = 1;

        var payees = buildPayees(signers[0].address, signers[1].address, signers[2].address, token)
        await ucvManager.setupPayroll("0x00", 1, startTime, period, payTimes, payees);


        var results = await ucvManager.getPayIDs(1, 1, 10);

        console.log("payIDs: ", results);
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






    async function tallyVotes (daoAddress:string, proposalID:string ) {

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);

        var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);

        console.log("vote detail the vote committee :", committeeInfo);
        var voteIdentity = {"proposalID":proposalID, "step":committeeInfo.step};
        
        await theVoteCommittee.tallyVotes(voteIdentity, "0x00");
        
    }


})