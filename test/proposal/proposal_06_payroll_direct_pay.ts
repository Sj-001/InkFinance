
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { MockNFTFixture ,FactoryManagerFixture, InkERC20Fixture, PAYROLL_UCV_KEY, PAYROLL_UCV_MANAGER_KEY } from '../shared/fixtures'; 

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

    it("test setup treasury for direct pay", async function () {

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

        var proposal = buildTreasurySetupProposal(signers[0].address, signers[0].address, signers[0].address, signers[0].address);
        
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
        
        await depositBalanceToUCV(masterDAO.address, erc20Address);

        await setupAndSignVaultDirectPay(masterDAO.address, erc20Address);

        await setupAndSignInvestmentDirectPay(masterDAO.address, erc20Address);

        await setupAndSignInvestmentDirectPayNFT(masterDAO.address, erc20Address);



    


    });


    async function depositBalanceToUCV(daoAddress:string, token:string) {
        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        
        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);
        var ucvAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_KEY);
        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");

        // const erc20 = await ethers.getContractAt("IERC20", token);
        const erc20 = await ethers.getContractAt("InkERC20", token);
        const ucvManager = await ethers.getContractAt("PayrollUCVManager", ucvManagerAddress);
        const ucv = await ethers.getContractAt("PayrollUCV", ucvAddress);


        console.log("previous chain token balance:",  await ethers.provider.getBalance(signers[0].address));

        console.log("previous erc20 token balance:", await erc20.balanceOf(ucvAddress))
        var ethAmount = ethers.utils.parseEther("10");
        var tokenAmount = ethers.utils.parseEther("100000");

        await erc20.mintTo(signers[0].address, tokenAmount);

        console.log("signer chain token balance: ", await erc20.balanceOf(signers[0].address));
        console.log("signer token balance: ", await erc20.balanceOf(signers[0].address));

        await erc20.approve(ucvAddress, tokenAmount);
        
        await ucv.depositToUCV("item1", token, 20, 0, tokenAmount, "remark");

        await ucv.depositToUCV("item2", "0x0000000000000000000000000000000000000000", 20, 0, ethAmount, "remark",{value: ethAmount});

        // const transactionHash = await signers[0].sendTransaction({
        //     to: ucvAddress,
        //     value: ethAmount, // Sends exactly 1.0 ether
        //   });

        console.log("after deposit chain token balance:", await ethers.provider.getBalance(ucvAddress))

        console.log("after deposit erc20 token balance:", await erc20.balanceOf(ucvAddress))






    }


    async function setupAndSignVaultDirectPay(daoAddress:string, token:string) {

        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        
        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);
        var ucvAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_KEY);
        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");

        const erc20 = await ethers.getContractAt("InkERC20", token);
    
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);
        var timestamp = Date.now();
        var sec = Math.floor(timestamp / 1000);

        var startTime = sec - 60 * 60 * 24;
        var period = 60 * 60;
        var payTimes = 1;
 
        var payees = [];
        // payee, token address, token type, token amount, token id
        payees[0] = web3.eth.abi.encodeParameters(["address", "address", "uint256", "uint256", "uint256", "bytes"], [signers[1].address, token, 20, 100, 0, web3.eth.abi.encodeParameter("string", "desc1" )]);
        await ucvManager.setupPayroll("0x00", 3, startTime, period, payTimes, payees);

        var results = await ucvManager.getPayIDs(1, 1, 10);

        console.log("start date:", new Date(startTime * 1000))

        for(var i=0;i<results.length;i++) {
            console.log("payID:", results[i][0], ", actual pay time:", new Date(results[i][1] * 1000));
        }

        // console.log("sign time:", await ucvManager.getSignTime(1,1, signers[1].address));

        await ucvManager.signPayID(1,1);

        console.log("after transfer erc20 token balance:", await erc20.balanceOf(ucvAddress))

        console.log("after transfer erc20 token balance:", await erc20.balanceOf(signers[1].address))

    }


    async function setupAndSignInvestmentDirectPay(daoAddress:string, token:string) {

        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        

        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);
        var ucvAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_KEY);
        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);
        var timestamp = Date.now();
        var sec = Math.floor(timestamp / 1000);

        var startTime = sec - 60 * 60 * 5;
        var period = 60 * 60;
        var payTimes = 10;

        var payees = [];
        // payee, token address, token type, token amount, token id
        payees[0] = web3.eth.abi.encodeParameters(["address", "address", "uint256", "uint256", "uint256", "bytes"], [signers[0].address, token, 20, 200, 0, web3.eth.abi.encodeParameter("string", "desc1" )]);
        await ucvManager.setupPayroll("0x00", 2, startTime, period, payTimes, payees);


        const erc20 = await ethers.getContractAt("InkERC20", token);

        var results = await ucvManager.getPayIDs(2, 1, 10);

        console.log("start date:", new Date(startTime * 1000))
        for(var i=0;i<results.length;i++) {
            console.log("payID:", results[i][0], ", actual pay time:", new Date(results[i][1] * 1000));
        }

        console.log("before sign erc20 token balance:", await erc20.balanceOf(signers[0].address));

        await ucvManager.signPayID(2,1);
        
        console.log("after transfer erc20 token balance:", await erc20.balanceOf(ucvAddress))

        console.log("after transfer erc20 token balance:", await erc20.balanceOf(signers[0].address))
    }


    async function setupAndSignInvestmentDirectPayNFT(daoAddress:string, token:string) {

        const signers = await ethers.getSigners();

        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(daoAddress);
        

        var ucvManagerAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_MANAGER_KEY);
        var ucvAddress = await masterDAO.getDeployedContractByKey(PAYROLL_UCV_KEY);
        var ucvManagerFactory = await ethers.getContractFactory("PayrollUCVManager");
        var ucvManager = await ucvManagerFactory.attach(ucvManagerAddress);

        const ucv = await ethers.getContractAt("PayrollUCV", ucvAddress);
        // deposit NFT
        const {mockNFT} = await loadFixture(MockNFTFixture);
        await mockNFT.mint(10);

        await mockNFT.approve(ucvAddress, 1);
        await mockNFT.approve(ucvAddress, 2);

        await ucv.depositToUCV("item3", mockNFT.address, 721, 1, 0, "remark");
        await ucv.depositToUCV("item4", mockNFT.address, 721, 2, 0, "remark");


        console.log("ucv token balance:", await mockNFT.balanceOf(ucv.address))


        var timestamp = Date.now();
        var sec = Math.floor(timestamp / 1000);

        var startTime = sec - 60 * 60;
        var period = 60 * 60;
        var payTimes = 1;

        var payees = [];
        // payee, token address, token type, token amount, token id
        payees[0] = web3.eth.abi.encodeParameters(["address", "address", "uint256", "uint256", "uint256", "bytes"], [signers[0].address, mockNFT.address, 721, 0, 1,  web3.eth.abi.encodeParameter("string", "desc1" )]);
        await ucvManager.setupPayroll("0x00", 2, startTime, period, payTimes, payees);

        var results = await ucvManager.getPayIDs(3, 1, 10);

        console.log("start date:", new Date(startTime * 1000))
        for(var i=0;i<results.length;i++) {
            console.log("payID:", results[i][0], ", actual pay time:", new Date(results[i][1] * 1000));
        }

        console.log("before sign erc721 token balance:", await mockNFT.balanceOf(signers[0].address));

        await ucvManager.signPayID(3,1);
        
        console.log("after transfer erc721 token balance:", await mockNFT.balanceOf(signers[0].address))








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