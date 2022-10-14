
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import {defaultAbiCoder} from '@ethersproject/abi';
import {PROPOSAL_HANDLER_KEY, PAYROLL_SETUP_AGENT_KEY, THE_TREASURY_COMMITTEE_KEY, THE_TREASURY_MANAGER_AGENT_KEY,FACTORY_MANAGER_KEY, PROPOSER_DUTYID, VOTER_DUTYID, INK_CONFIG_DOMAIN, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, PAYROLL_EXECUTE_AGENT_KEY } from '../shared/fixtures';  
const {loadFixture, deployContract} = waffle;



export function buildMasterDAOInitData(erc20Address:string, defaultFlowIndex:number) {
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

        var theBoardCommitteeDutyIDsBytesArrary = [];
        theBoardCommitteeDutyIDsBytesArrary[0] = PROPOSER_DUTYID;
        theBoardCommitteeDutyIDsBytesArrary[1] = VOTER_DUTYID;

        var theBoardCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", theBoardCommitteeDutyIDsBytesArrary);
        // console.log("board duty bytes----:   ", theBoardCommitteeDutyIDs)
        var thePublicCommitteeDutyIDsByteArray = [];
        thePublicCommitteeDutyIDsByteArray[0] = "0x0000000000000000000000000000000000000000000000000000000000000000";
        var thePublicCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", thePublicCommitteeDutyIDsByteArray);

        
        /* 
        struct CommitteeCreateInfo {
            string committeeName;
            bytes32 step;
            bytes32 addressConfigKey;
            bytes dutyIDs;
        }
        */
        var committeeInFlowTuple = 'tuple(string, bytes32, bytes32, bytes)';
        var flow0Committees = [];
        flow0Committees[0] = ["The Board", keccak256(toUtf8Bytes("board vote")), THE_BOARD_COMMITTEE_KEY, theBoardCommitteeDutyIDs];

        var flow1Committees = [];
        flow1Committees[0] = ["The Public", keccak256(toUtf8Bytes("public vote")), THE_PUBLIC_COMMITTEE_KEY, thePublicCommitteeDutyIDs];
        flow1Committees[1] = ["The Board", keccak256(toUtf8Bytes("board vote")), THE_BOARD_COMMITTEE_KEY, theBoardCommitteeDutyIDs]; 

        var flow2Committees = [];
        flow2Committees[0] = ["The Public", keccak256(toUtf8Bytes("public vote")), THE_PUBLIC_COMMITTEE_KEY, thePublicCommitteeDutyIDs]; 


        var flows = [];
        var flowTuple = 'tuple(bytes32, ' + committeeInFlowTuple +'[])';
        // flows[0] = defaultAbiCoder.encode(['tuple(bytes32, ' + proposalTuple +'[])'], [[flowID, committees]]);
        // flows[0] = [keccak256(toUtf8Bytes("0")), committees];
        if (defaultFlowIndex == 0) {
            flows[0] = ["0x0000000000000000000000000000000000000000000000000000000000000000", flow0Committees];
            flows[1] = ["0x0000000000000000000000000000000000000000000000000000000000000001", flow1Committees];
            flows[2] = ["0x0000000000000000000000000000000000000000000000000000000000000002", flow2Committees];
        }

        if (defaultFlowIndex == 1) {

            flows[0] = ["0x0000000000000000000000000000000000000000000000000000000000000001", flow1Committees];
            flows[1] = ["0x0000000000000000000000000000000000000000000000000000000000000002", flow2Committees];
        }

        if (defaultFlowIndex == 2) {
            flows[0] = ["0x0000000000000000000000000000000000000000000000000000000000000002", flow2Committees];
        }
        
        var mds = [];
        mds[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")), "0x00"]);


        var badgeName = "badgeName1";
        var badgeTotal = ethers.utils.parseEther("10000000");
        var daoLogo = "daoDefaultLogo";
        var minPledgeRequired = 10;
        var minEffectiveVotes = 1;
        var minEffectiveVoteWallets = 1;


        // committee info
        var committesInfo = [];
        // name | committeeKey | dutyIDs
        committesInfo[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["The Board", THE_BOARD_COMMITTEE_KEY , theBoardCommitteeDutyIDs]);
        committesInfo[1] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["The Public", THE_PUBLIC_COMMITTEE_KEY , thePublicCommitteeDutyIDs]);



        var tupleSting = ['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256, bytes32, uint256,' + flowTuple +'[], bytes32, bytes[])'];
        var tupleData = ["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets, FACTORY_MANAGER_KEY, defaultFlowIndex, flows, PROPOSAL_HANDLER_KEY, committesInfo];
        var masterDAOInitialData = defaultAbiCoder.encode(tupleSting,
             [tupleData]);
        // console.log("dao init data:", masterDAOInitialData);

        // masterDAOInitialData = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000001e0000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000002400000000000000000000000000e7100a8c3695fe0b61f17457eaa141c9af4069a00000000000000000000000000000000000000000000000000000000000186a00000000000000000000000000e7100a8c3695fe0b61f17457eaa141c9af4069a0000000000000000000000000000000000000000000000000000000000000380000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000003c00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000025488dc73a58b121c81b942c8a2da9c440f0f5e23c05019dbdc5cf547c661e114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e0000000000000000000000000000000000000000000000000000000000000000b44414f4c4f474f5445535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000060b9591d9b1e803376f164fbb8b517080722ff3aa335606ac59bc773a05aabfe5a00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000007636f6e74656e74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000013200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000005400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000008095c7b40b2a40a597fe493e4e2cc0f6f669c3aba068b4679292b3e70803e3ed1fc807c06d810f70a69645cefa8f2245f58499fbf7fac417aee813126af6eac59200000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000954686520426f61726400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000014e8ece298094d647fede4b4eac261057852af2e00c03eec1ecb4e66201f71acd000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000080d8d9f94caeec90164ca50ac3006287d470d3ba165507a38695012a481e57b3a8a0f31f21149d1bd033644265f5b4ecaa082df065845083778e64026d759c323800000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000a546865205075626c696300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001fc12ec87eb906e85ab5d6479be2bc122a313c74c5e744d48ef17d9253e6dd6ba000000000000000000000000000000000000000000000000000000000000008095c7b40b2a40a597fe493e4e2cc0f6f669c3aba068b4679292b3e70803e3ed1fc807c06d810f70a69645cefa8f2245f58499fbf7fac417aee813126af6eac59200000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000954686520426f61726400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000014e8ece298094d647fede4b4eac261057852af2e00c03eec1ecb4e66201f71acd00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000080d8d9f94caeec90164ca50ac3006287d470d3ba165507a38695012a481e57b3a8a0f31f21149d1bd033644265f5b4ecaa082df065845083778e64026d759c323800000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000954686520426f6172640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001fc12ec87eb906e85ab5d6479be2bc122a313c74c5e744d48ef17d9253e6dd6ba";
        // console.log("tuple:", tupleSting);
        // console.log("tuple data:", tupleData);
        return masterDAOInitialData;
        
}




export function buildOffchainProposal() {
        // create agent
        var agents = []
        agents[0] = "0x0000000000000000000000000000000000000000000000000000000000000000";
        
        var headers = [];
        headers[0] = {
            "key":  "MinEffectiveVotes",
            "typeID": keccak256(toUtf8Bytes("type.UINT256")),
            "data": web3.eth.abi.encodeParameter("uint256", 99),
            "desc": "0x0002",
        };

        headers[1] = {
            "key":  "MinEffectiveVoteWallets",
            "typeID": keccak256(toUtf8Bytes("type.UINT256")),
            "data": web3.eth.abi.encodeParameter("uint256", 99),
            "desc": toUtf8Bytes(""),
        };

        headers[2] = {
            "key":  "VoteFlow",
            "typeID": keccak256(toUtf8Bytes("type.BYTES32")),
            "data": "0x0000000000000000000000000000000000000000000000000000000000000002",
            "desc": toUtf8Bytes(""),
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
    // agent - related duties
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

    // kvData[0] = {
    //     "key":  "key",
    //     "typeID": keccak256(toUtf8Bytes("typeID")),
    //     "data": "0x0001",
    //     "desc": "0x0002",
    // };
    //kvData[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);

    var kvData = [];
    // different roles
    // treasury operator 
    var treasuryOperator = [];
    treasuryOperator[0] = "0xf46B1E93aF2Bf497b07726108A539B478B31e64C";
    treasuryOperator[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    var treasuryOperatorBytes = web3.eth.abi.encodeParameter("address[]", treasuryOperator);
    // // treasury signer
    var treasurySigner = [];
    treasurySigner[0] = "0x6c555518C66e7152a282330853aBf6F83a7FD19a";
    var treasurySignerBytes = web3.eth.abi.encodeParameter("address[]", treasurySigner);
    // treasury auditor
    var treasuryAuditor = [];
    treasuryAuditor[0] = "0x7e2FFA4eF972500020f1fa85ca6b453E931F51aA";
    var treasuryAuditorBytes = web3.eth.abi.encodeParameter("address[]", treasuryAuditor);

    kvData[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["operators", keccak256(toUtf8Bytes("address")), treasuryOperatorBytes]);
    kvData[1] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["signer", keccak256(toUtf8Bytes("address")), treasurySignerBytes]);
    kvData[2] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["auditor", keccak256(toUtf8Bytes("address")), treasuryAuditorBytes]);


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
    // console.log("member bytes:", memberListBytes);

    var kvData = [];

    var timestamp = Date.now();
    var sec = Math.floor(timestamp / 1000);
    console.log("now time ################################################################# ", sec);

    var startTimeBytes = web3.eth.abi.encodeParameter("uint256", (sec - 100));
    var periodBytes = web3.eth.abi.encodeParameter("uint256",5 );
    var claimTimesByte = web3.eth.abi.encodeParameter("uint256",100);


    kvData[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["members", keccak256(toUtf8Bytes("list")), memberListBytes]) ;
    kvData[1] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["startTime", keccak256(toUtf8Bytes("uint256")), startTimeBytes]) ;
    kvData[2] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["period", keccak256(toUtf8Bytes("uint256")), periodBytes]) ;
    kvData[3] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["claimTimes", keccak256(toUtf8Bytes("uint256")), claimTimesByte]) ;

    // 0x0000000000000000000000000000000000000000000000000000000000000000
    // 0x0000000000000000000000000000000000000000000000000000000000000000
    var proposal = {
        "agents" : agents,
        "topicID" : "0x0000000000000000000000000000000000000000000000000000000000000000",
        "crossChainProtocal":toUtf8Bytes(""),
        "metadata" : headers,
        "kvData" : kvData
    }

    return proposal;
}



export function buildPayrollPayProposal(topicID:string, managerAddress:string) {

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
        "key":  "anyKey",
        "typeID": keccak256(toUtf8Bytes("typeID")),
        "data": "0xf46B1E93aF2Bf497b07726108A539B478B31e64C",
        "desc": "0x0002",
    };

    // include vote rule, require all the "signer to vote pass"
    // console.log("start member bytes encode:");
    // var memberItemTuple = 'tuple(address, address, uint256, string)[]';
    var memberListBytes = "0x00";
    // console.log("member bytes:", memberListBytes);


    var signClaimTimes = web3.eth.abi.encodeParameter("uint256", 1);
    var managerAddressBytes = web3.eth.abi.encodeParameter("address", managerAddress);

    console.log("PAYROLL's topicID is ::::: ", topicID);

    var kvData = [];
    kvData[0] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["topicID", keccak256(toUtf8Bytes("bytes32")), topicID]) ;
    kvData[1] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["approveTimes", keccak256(toUtf8Bytes("uint256")), signClaimTimes]) ;
    kvData[2] = web3.eth.abi.encodeParameters(["string", "bytes32", "bytes"], ["managerAddress", keccak256(toUtf8Bytes("address")), managerAddressBytes]) ;
    // kvData[0] = {
    //     "key":  "key",
    //     "typeID": keccak256(toUtf8Bytes("typeID")),
    //     "data": "0x0001",
    //     "desc": "0x0002",
    // };

    var proposal = {
        "agents" : agents,
        "topicID" : topicID,
        "crossChainProtocal":toUtf8Bytes(""),
        "metadata" : headers,
        "kvData" : kvData
    }

    return proposal;
}