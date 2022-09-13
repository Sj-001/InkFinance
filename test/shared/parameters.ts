
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import {defaultAbiCoder} from '@ethersproject/abi';
import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
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
        var committees = [];

        var theBoardCommitteeDutyIDsBytesArrary = [];
        theBoardCommitteeDutyIDsBytesArrary[0] = PROPOSER_DUTYID;
        var theBoardCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", theBoardCommitteeDutyIDsBytesArrary);
        console.log("board duty bytes----:   ", theBoardCommitteeDutyIDs)
        var thePublicCommitteeDutyIDsByteArray = [];
        thePublicCommitteeDutyIDsByteArray[0] = VOTER_DUTYID;
        var thePublicCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", thePublicCommitteeDutyIDsByteArray);


        var proposalTuple = 'tuple(bytes32, string, uint256, bytes)';
        committees[0] = [keccak256(toUtf8Bytes("generate proposal")), theBoard_ContractID, 1, theBoardCommitteeDutyIDs]; 
        committees[1] = [keccak256(toUtf8Bytes("public vote")), thePublic_ContractID, 0, thePublicCommitteeDutyIDs];

        var flows = [];
        var flowTuple = 'tuple(bytes32, ' + proposalTuple +'[])';
        // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[flowID, committees]]);
        flows[0] = [keccak256(toUtf8Bytes("0")), committees];

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