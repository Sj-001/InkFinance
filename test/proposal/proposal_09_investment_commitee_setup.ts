import chai from "chai";
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, FUND_MANAGER_KEY, InkERC20Fixture } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { INVESTMENT_COMMITTEE_KEY, INK_CONFIG_DOMAIN, THE_TREASURY_MANAGER_AGENT_KEY, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
import { FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID } from '../shared/fixtures'; 
import { buildFundInitData, buildMasterDAOInitData, buildInvestmentSetupProposal } from '../shared/parameters'; 

const { expect } = chai;
import {defaultAbiCoder} from '@ethersproject/abi';


const {loadFixture, deployContract} = waffle;

describe("proposal related test", function () {

    it("test create investment-setup proposal ", async function () {

        const signers = await ethers.getSigners();
        console.log("########################current signer:", signers[0].address);
        
        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);        
        var erc20Address = inkERC20.address;

        // // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address, 0);
        await factoryManager.deploy(true, DAOTypeID,MASTER_DAO_KEY,masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = masterDAOFactory.attach(firstDAOAddress);
        console.log("dao address:", masterDAO.address);
        // // select one flow of the DAO

        var proposal = buildInvestmentSetupProposal(signers[0].address, signers[0].address, signers[0].address, signers[0].address, signers[0].address);

        // var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        proposal.metadata[2] =  {
            "key":  "VoteFlow",
            "typeID": keccak256(toUtf8Bytes("type.BYTES32")),
            "data": "0x0000000000000000000000000000000000000000000000000000000000000000",
            "desc": "0x0002",
        };

        proposal.metadata[3] = {
            "key":  "Expiration",
            "typeID": keccak256(toUtf8Bytes("type.UINT256")),
            "data":  web3.eth.abi.encodeParameter("uint256", 1),
            "desc":  "0x0002",
        };

        console.log("proposal:", proposal);

        var theBoardAddress = await masterDAO.getDeployedContractByKey(THE_BOARD_COMMITTEE_KEY);
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        // var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        var theBoard = theBoardFactory.attach(theBoardAddress);

        await theBoard.newProposal(proposal, true, "0x00");

        console.log("committee infos:", await masterDAO.getDAOCommittees());

        var proposalID = await masterDAO.getProposalIDByIndex(0);
        
        console.log("proposal flow:", await masterDAO.getProposalFlow(proposalID))


        await voteProposalByTheBoard(await masterDAO.address, proposalID);

        await tallyVotesByTheBoard(await masterDAO.address,  proposalID);

        // console.log("first proposal id: ", proposalID);
        // console.log("proposal summery:", proposalSummery);

        var committeeAddress = await masterDAO.getDeployedContractByKey(INVESTMENT_COMMITTEE_KEY);

        await setupFund(masterDAO.address, erc20Address);

        // await launchFund(committeeAddress, erc20Address);


        // await voteAndInvestTheFund();
        
        // await withdrawPrincipal()


    });


    async function setupFund (daoAddress:string, erc20Address:string) {


        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManagerAddress = await masterDAO.getDeployedContractByKey(FUND_MANAGER_KEY);
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var fundInitData = buildFundInitData(erc20Address); 


        await fundManager.createFund(fundInitData);

    }

    async function launchFund (committeeAddress:string, erc20Address:string) {


    }


    async function purchaseFund (committeeAddress:string, erc20Address:string) {



    }

    async function tallyUp (committeeAddress:string, erc20Address:string) {

    }


    async function startFund (committeeAddress:string, erc20Address:string) {


    }

    async function claimShare(committeeAddress:string, erc20Address:string) {


    }


    async function claimPrincipal (committeeAddress:string, erc20Address:string) {


    }

    async function voteProposalByThePublic(daoAddress:string, proposalID:string) {
        const signers = await ethers.getSigners();
        console.log("voteProposalByThePublic proposalID", proposalID);

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var thePublicAddress = await masterDAO.getDeployedContractByKey(THE_PUBLIC_COMMITTEE_KEY);

        console.log("voteProposalByThePublic vote committee info:", await thePublicAddress);

        const theVoteCommittee = await ethers.getContractAt("ThePublic", thePublicAddress);
        var voteIdentity = {"proposalID":proposalID, "step": "0x0000000000000000000000000000000000000000000000000000000000000000"};
        
        await theVoteCommittee.connect(signers[1]).vote(voteIdentity, true, 1000, "", "0x00");

    }

    async function voteProposalByTheBoard(daoAddress:string, proposalID:string) {
        
        console.log("voteProposalByTheBoard proposalID", proposalID);

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var theBoardAddress = await masterDAO.getDeployedContractByKey(THE_BOARD_COMMITTEE_KEY);

        console.log("voteProposalByTheBoard vote committee info:", await theBoardAddress);

        const theVoteCommittee = await ethers.getContractAt("TheBoard", theBoardAddress);
        var voteIdentity = {"proposalID":proposalID, "step": "0x0000000000000000000000000000000000000000000000000000000000000000"};
        

        await theVoteCommittee.vote(voteIdentity, true, 1, "", "0x00");

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
        var voteIdentity = {"proposalID":proposalID, "step":"0x0000000000000000000000000000000000000000000000000000000000000000"};
        
        await theVoteCommittee.tallyVotes(voteIdentity, "0x00");
        
    }


    async function tallyVotesByTheBoard (daoAddress:string, proposalID:string ) {

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);

        var committeeInfo = await masterDAO.getNextVoteCommitteeInfo(proposalID);

        var theVoteCommitteeFactory = await ethers.getContractFactory("TheBoard");
        var theVoteCommittee = await theVoteCommitteeFactory.attach(committeeInfo.committee);

        console.log("vote detail the vote committee :", committeeInfo);
        var voteIdentity = {"proposalID":proposalID, "step":"0x0000000000000000000000000000000000000000000000000000000000000000"};
        
        await theVoteCommittee.tallyVotes(voteIdentity, "0x00");
        
    }

})