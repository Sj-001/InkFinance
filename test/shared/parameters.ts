
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import {defaultAbiCoder} from '@ethersproject/abi';

import { masterDAO_ContractID, theBoard_ContractID, thePublic_ContractID, treasuryCommittee_ContractID} from './fixtures'; 
const {loadFixture, deployContract} = waffle;



export function buildMasterDAOInitData(erc20Address:string) {

        /* 
        MasterDAOInitData
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        string badgeName;
        uint256 badgeTotal;
        string daoLogo;
        uint256 minPledgeRequired;
        uint256 minEffectiveVotes;
        uint256 minEffectiveVoteWallets;
        FlowInfo[] flows;
        */
        var stakingAddress = erc20Address;
        /*
        struct ProposalCommitteeInfo {
            bytes32 step;
            string committeeFactoryID;
            uint256 sensitive;
            string name;
        }
        */
        var proposalCommittees = [];
        var proposalTuple = 'tuple(bytes32, string, uint256)';
        // proposalCommittees[0] = defaultAbiCoder.encode([proposalTuple], [[keccak256(toUtf8Bytes("generate proposal")), theBoard_ContractID, 1, "The Board"]]); 
        // proposalCommittees[1] = defaultAbiCoder.encode([proposalTuple], [[keccak256(toUtf8Bytes("public vote")), thePublic_ContractID, 1, "The Public"]]);
        proposalCommittees[0] = [keccak256(toUtf8Bytes("generate proposal")), theBoard_ContractID, 1]; 
        proposalCommittees[1] = [keccak256(toUtf8Bytes("public vote")), thePublic_ContractID, 1];

        var flows = [];
        var flowTuple = 'tuple(bytes32, ' + proposalTuple +'[])';
        // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[theBoard_ContractID, proposalCommittees]]);
        flows[0] = [theBoard_ContractID, proposalCommittees];

        var mds = [];
        mds[0] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content1"));
        mds[1] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content2"));
        mds[2] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content3"));

        var badgeName = "badgeName1";
        var badgeTotal = 100;
        var daoLogo = "daoDefaultLogo";
        var minPledgeRequired = 10;
        var minEffectiveVotes = 100;
        var minEffectiveVoteWallets = 1;

        var masterDAOInitialData = defaultAbiCoder.encode(['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256, ' + flowTuple +'[])'],
             [["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets, flows]]);

        return masterDAOInitialData;
        
}