
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import {defaultAbiCoder} from '@ethersproject/abi';
import {PAYROLL_SETUP_AGENT_KEY, THE_TREASURY_COMMITTEE_KEY, THE_TREASURY_MANAGER_AGENT_KEY,FACTORY_MANAGER_KEY, PROPOSER_DUTYID, VOTER_DUTYID, INK_CONFIG_DOMAIN, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, PAYROLL_EXECUTE_AGENT_KEY } from '../shared/fixtures';  
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




export function buildOffchainProposal() {
        // create agent
        var agents = []
        agents[0] = "0x0000000000000000000000000000000000000000000000000000000000000000";
        
        var headers = [];
        headers[0] = {
            "key":  "key0",
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
            "desc": "0x0002",
        };

        headers[1] = {
            "key":  "key1",
            "typeID": keccak256(toUtf8Bytes("typeID")),
            "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
            "desc": "0x0002",
        };

        var kvData = [];
        kvData[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);
        // kvData[0] = {
        //     "key":  "key",
        //     "typeID": keccak256(toUtf8Bytes("typeID")),
        //     "data": "0x0001",
        //     "desc": "0x0002",
        // };
        var proposal = {
            "agents" : agents,
            "topicID" : keccak256(toUtf8Bytes("topic")),
            "crossChainProtocal":toUtf8Bytes(""),
            "metadata" : headers,
            "kvData" : kvData
        }

        return proposal;
}

export function buildTreasurySetupProposal() {

    var agents = []
    agents[0] = THE_TREASURY_MANAGER_AGENT_KEY;
    
    // agents[1] = toUtf8Bytes("");
    var headers = [];
    headers[0] = {
        "key":  "committeeKey",
        "typeID": THE_TREASURY_COMMITTEE_KEY,
        // "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": THE_TREASURY_COMMITTEE_KEY,
        "desc": "0x0002",
    };
    
    headers[1] = {
        "key":  "controllerAddress",
        "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
        "desc": "0x0002",
    };

    var kvData = [];
    kvData[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);
    // kvData[0] = {
    //     "key":  "key",
    //     "typeID": keccak256(toUtf8Bytes("typeID")),
    //     "data": "0x0001",
    //     "desc": "0x0002",
    // };


    var proposal = {
        "agents" : agents,
        "topicID" : keccak256(toUtf8Bytes("topic")),
        "crossChainProtocal":toUtf8Bytes(""),
        "metadata" : headers,
        "kvData" : kvData
    }

    return proposal;
}


export function buildPayrollSetupProposal(erc20Address:string) {

    var agents = []
    agents[0] = PAYROLL_SETUP_AGENT_KEY;
    
    // agents[1] = toUtf8Bytes("");
    var headers = [];

    // setup member and schedule and payments.

    headers[0] = {
        "key":  "committeeKey",
        "typeID": THE_TREASURY_COMMITTEE_KEY,
        // "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": THE_TREASURY_COMMITTEE_KEY,
        "desc": "0x0002",
    };
    
    headers[1] = {
        "key":  "controllerAddress",
        "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
        "desc": "0x0002",
    };

    
    // var memberItem = {
    //     addr:  "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
    //     coin: erc20Address,
    //     oncePay:  10000000,
    //     desc: "payroll",
    // };


    var memberList = [];
    memberList[0] = ["0xf46B1E93aF2Bf497b07726108A539B478B31e64C", erc20Address, 10000000, "payroll"]; ;

    console.log("start member bytes encode:");
    var memberItemTuple = 'tuple(address, address, uint256, string)[]';
    var memberListBytes = defaultAbiCoder.encode([memberItemTuple],[memberList]);
    console.log("member bytes:", memberListBytes);

    var kvData = [];
    kvData[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["members", keccak256(toUtf8Bytes("list")), memberListBytes]) ;


    // kvData[0] = {
    //     "key":  "key",
    //     "typeID": keccak256(toUtf8Bytes("typeID")),
    //     "data": "0x0001",
    //     "desc": "0x0002",
    // };

    var proposal = {
        "agents" : agents,
        "topicID" : keccak256(toUtf8Bytes("topic")),
        "crossChainProtocal":toUtf8Bytes(""),
        "metadata" : headers,
        "kvData" : kvData
    }

    return proposal;
}



export function buildPayrollPayProposal(proposalID:string) {

    var agents = []
    agents[0] = PAYROLL_EXECUTE_AGENT_KEY;
    
    // agents[1] = toUtf8Bytes("");
    var headers = [];

    // setup member and schedule and payments.

    headers[0] = {
        "key":  "committeeKey",
        "typeID": THE_TREASURY_COMMITTEE_KEY,
        // "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": THE_TREASURY_COMMITTEE_KEY,
        "desc": "0x0002",
    };
    
    headers[1] = {
        "key":  "controllerAddress",
        "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
        "desc": "0x0002",
    };


    // include vote rule, require all the "signer to vote pass"
    

    // var memberItem = {
    //     addr:  "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
    //     coin: erc20Address,
    //     oncePay:  10000000,
    //     desc: "payroll",
    // };


    // var memberList = [];
    // memberList[0] = ["0xf46B1E93aF2Bf497b07726108A539B478B31e64C", erc20Address, 10000000, "payroll"]; ;

    // console.log("start member bytes encode:");
    // var memberItemTuple = 'tuple(address, address, uint256, string)[]';
    var memberListBytes = "0x00";
    // console.log("member bytes:", memberListBytes);

    var kvData = [];
    kvData[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["members", keccak256(toUtf8Bytes("list")), memberListBytes]) ;


    // kvData[0] = {
    //     "key":  "key",
    //     "typeID": keccak256(toUtf8Bytes("typeID")),
    //     "data": "0x0001",
    //     "desc": "0x0002",
    // };

    var proposal = {
        "agents" : agents,
        "topicID" : proposalID,
        "crossChainProtocal":toUtf8Bytes(""),
        "metadata" : headers,
        "kvData" : kvData
    }

    return proposal;
}