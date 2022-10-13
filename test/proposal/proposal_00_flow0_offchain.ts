import chai from "chai";
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 
const { expect } = chai;
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

describe("proposal_00_flow0_offchain", function () {


    it("test create off-chain proposal - flow 0 - Board Only ", async function () {
        
        const signers = await ethers.getSigners();

        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);        
        var erc20Address = inkERC20.address;

        // select/create a DAO
        var masterDAOInitialData = buildMasterDAOInitData(erc20Address, 0);
        await factoryManager.deploy(true, DAOTypeID, MASTER_DAO_KEY,masterDAOInitialData);

        var firstDAOAddress = await factoryManager.getDeployedAddress(MASTER_DAO_KEY, 0);
        var masterDAOFactory = await ethers.getContractFactory("MasterDAO");
        var masterDAO = await masterDAOFactory.attach(firstDAOAddress);        
        var offchainProposal = buildOffchainProposal();
        var flowSteps = await masterDAO.getFlowSteps("0x0000000000000000000000000000000000000000000000000000000000000000");
        var theBoardFactory = await ethers.getContractFactory("TheBoard");
        var theBoard = theBoardFactory.attach(flowSteps[0].committee);
        
        await theBoard.newProposal(offchainProposal, true, "0x00");
        var proposalID = await masterDAO.getProposalIDByIndex(0);

        var proposalSummery = await masterDAO.getProposalSummary(proposalID);

        console.log(await masterDAO.getTallyVoteRules(proposalID));
        console.log("Proposal Flow: ", await masterDAO.getProposalFlow(proposalID));
        console.log("DAO Flow: ", await masterDAO.getDAOTallyVoteRules());
        console.log("DAO Supported Flow: ", await masterDAO.getSupportedFlow());

        expect(proposalSummery.status).to.be.equal(0);



        console.log("committee infos:", await masterDAO.getDAOCommittees(signers[0].address));




    });
    


})