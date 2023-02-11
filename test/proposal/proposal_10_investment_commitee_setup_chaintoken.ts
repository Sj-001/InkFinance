import chai from "chai";
import {Wallet, Contract, BigNumber} from "ethers";
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
import { buildFundInitData2, buildFundInitData, buildMasterDAOInitData, buildInvestmentSetupProposal } from '../shared/parameters'; 

const { expect } = chai;
import {defaultAbiCoder} from '@ethersproject/abi';

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
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
        // select one flow of the DAO

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

        var fundManagerAddress = await masterDAO.getDeployedContractByKey(FUND_MANAGER_KEY);


        var minRaise = ethers.utils.parseEther("1000");
        var maxRaise = ethers.utils.parseEther("10000");



        await setupFund(fundManagerAddress, erc20Address);

        await launchFund(fundManagerAddress);


        await purchaseFund(fundManagerAddress, erc20Address);
        




        // // fund manager start to invest
        // // transfer fixed fee to treasury
        // // issue voucher for investor to claim
        await startFund(fundManagerAddress);

        await makeDistribution(fundManagerAddress, erc20Address);

        // // // claim user's voucher
        // await claimShare(fundManagerAddress);

        // // // if fund raised failed, user should claim principal
        // await claimPrincipal(fundManagerAddress);

        // // user could claim principal and profit
        await tallyUp(fundManagerAddress);


        // await voteAndInvestTheFund();
        
        // await withdrawPrincipal()


    });


    async function setupFund (fundManagerAddress:string, erc20Address:string) {
        const signers = await ethers.getSigners();
        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        // var fundInitData = buildFundInitData(erc20Address, signers[0].address, signers[0].address); 
        // var fundInitData = buildFundInitData("0x0000000000000000000000000000000000000000", signers[0].address, signers[0].address); 
        var fundInitData = buildFundInitData2("0x0000000000000000000000000000000000000000", signers[0].address, signers[0].address); 

        await fundManager.createFund(fundInitData);

        var funds = await fundManager.getCreatedFunds();

        console.log("funds:", funds);

        console.log("fund launch status:", await fundManager.getLaunchStatus(funds[0]));

    }


    async function makeDistribution (fundManagerAddress:string, erc20Address:string) {
        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("funds:", funds);


        var distributions = {
            "token" : "0x0000000000000000000000000000000000000000",
            "amount" :  ethers.utils.parseEther("10")
        }

        // await fundManager.launchFund(funds[0]); // valid launch twice    
        console.log("fund launch status:", await fundManager.makeDistribution(funds[0], "remark content", distributions));
        const signers = await ethers.getSigners();

        const buyer1 = signers[0];
        console.log("check how many I could claim:", await fundManager.getClaimableDistributionAmount(funds[0], buyer1.address));
        
        const erc20 = await ethers.getContractAt("InkERC20", erc20Address);
        console.log("balance of buyer1(before):", await erc20.balanceOf(buyer1.address));
        
        console.log("claim :", await fundManager.claimDistribution(funds[0]));

        console.log("balance of buyer1(after):", await erc20.balanceOf(buyer1.address));
    }

    async function launchFund (fundManagerAddress:string) {
        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("funds:", funds);
        console.log("fund launch status:", await fundManager.getLaunchStatus(funds[0]));
        await fundManager.launchFund(funds[0]);

        // await fundManager.launchFund(funds[0]); // valid launch twice
        console.log("fund launch status:", await fundManager.getLaunchStatus(funds[0]));
        
    }


    async function purchaseFund (fundManagerAddress:string, erc20Address:string) {

        const signers = await ethers.getSigners();

        const buyer1 = signers[0];
        const buyer2 = signers[1];


        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("ready to purchase funds:", funds[0]);

        // const erc20 = await ethers.getContractAt("InkERC20", erc20Address);
        
        // get fund(ucv) address to purchase the share
        const fundAddress = await fundManager.getFund(funds[0]);

        console.log("fund address:", fundAddress)
        const fund = await ethers.getContractAt("InkFund", fundAddress);

        // var tokenAmount = ethers.utils.parseEther("1000");

        // await erc20.mintTo(signers[0].address, tokenAmount);
        // await erc20.mintTo(buyer2.address, tokenAmount);

        // await erc20.approve(fundAddress, tokenAmount);
        // await erc20.connect(buyer2).approve(fundAddress, tokenAmount);

        console.log("balance of fund(before):",   await web3.eth.getBalance(fundAddress));


        var buyer1PurchaseAmount = ethers.utils.parseEther("100");
        var buyer2PurchaseAmount = ethers.utils.parseEther("150");



        await fund.purchaseShare(buyer1PurchaseAmount, {value:buyer1PurchaseAmount});
        await fund.connect(buyer2).purchaseShare(buyer2PurchaseAmount, {value:buyer2PurchaseAmount});


        console.log("balance of fund(after):",  await web3.eth.getBalance(fundAddress));


        console.log("fund raised info:", await fund.getRaisedInfo());

        // console.log("buyer1 share:", await fund.getShare(buyer1.address));
        // console.log("buyer2 share:", await fund.getShare(buyer2.address));


        await sleep(10000);

        console.log("status:", await fundManager.getLaunchStatus(funds[0]));

    }

    async function startFund (fundManagerAddress:string) {
        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("ready to purchase funds:", funds[0]);

        // get fund(ucv) address to purchase the share
        const fundAddress = fundManager.getFund(funds[0]);
        const fund = await ethers.getContractAt("InkFund", fundAddress);
        
        await fundManager.startFund(funds[0]);

    }

    async function tallyUp (fundManagerAddress:string) {
        
        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("ready to purchase funds:", funds[0]);

        // get fund(ucv) address to purchase the share
        const fundAddress = fundManager.getFund(funds[0]);
        const fund = await ethers.getContractAt("InkFund", fundAddress);
        
        await fundManager.tallyUpFund(funds[0]);

    }

    async function claimShare(fundManagerAddress:string) {
        const signers = await ethers.getSigners();

        const buyer1 = signers[0];

        var fundManagerFactory = await ethers.getContractFactory("FundManager");
        var fundManager = await fundManagerFactory.attach(fundManagerAddress);

        var funds = await fundManager.getCreatedFunds();

        console.log("ready to purchase funds:", funds[0]);

        // get fund(ucv) address to purchase the share
        const fundAddress = fundManager.getFund(funds[0]);
        const fund = await ethers.getContractAt("InkFund", fundAddress);
        


        const certificateToken = await fund.getCertificateInfo();
        const erc20 = await ethers.getContractAt("InkERC20", certificateToken);
        // const token = await ethers.getContractAt("IERC20", certificateToken);
        
        // console.log("certi token:", certificateToken);
        // console.log("balance:", token.balanceOf(fundAddress));        
        await fundManager.claimFundShare(funds[0]);

        console.log("after claim balance:", await erc20.balanceOf(buyer1.address))


        

    }


    async function claimPrincipal (committeeAddress:string) {


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