
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import {defaultAbiCoder} from '@ethersproject/abi';
import {FACTORY_MANAGER_KEY, PROPOSER_DUTYID, VOTER_DUTYID, INK_CONFIG_DOMAIN, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY } from '../shared/fixtures';  
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
        // console.log("board duty bytes----:   ", theBoardCommitteeDutyIDs)
        var thePublicCommitteeDutyIDsByteArray = [];
        thePublicCommitteeDutyIDsByteArray[0] = VOTER_DUTYID;
        var thePublicCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", thePublicCommitteeDutyIDsByteArray);


        var proposalTuple = 'tuple(bytes32, bytes32, bytes)';
        committees[0] = [keccak256(toUtf8Bytes("generate proposal")), THE_BOARD_COMMITTEE_KEY, theBoardCommitteeDutyIDs]; 
        committees[1] = [keccak256(toUtf8Bytes("public vote")), THE_PUBLIC_COMMITTEE_KEY, thePublicCommitteeDutyIDs];

        var flows = [];
        var flowTuple = 'tuple(bytes32, ' + proposalTuple +'[])';
        // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[flowID, committees]]);
        // flows[0] = [keccak256(toUtf8Bytes("0")), committees];
        flows[0] = ["0x0000000000000000000000000000000000000000000000000000000000000000", committees];

        var mds = [];
        mds[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);


        var badgeName = "badgeName1";
        var badgeTotal = 100;
        var daoLogo = "daoDefaultLogo";
        var minPledgeRequired = 10;
        var minEffectiveVotes = 100;
        var minEffectiveVoteWallets = 1;

        var masterDAOInitialData = defaultAbiCoder.encode(['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256, bytes32, ' + flowTuple +'[])'],
             [["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets, FACTORY_MANAGER_KEY, flows]]);

        return masterDAOInitialData;
        
}