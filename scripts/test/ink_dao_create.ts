
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import {defaultAbiCoder} from '@ethersproject/abi';

// constant define

async function deploy(){

  // initial roles
  const signers = await ethers.getSigners();
  // admin
  var admin = signers[0].address;
  console.log("deploy InkFinance Governance Module V2 with this account: ", admin);

//  config address: 0xd711FcF5AB000Dc88c0Bb64B90Eb60858C0459fD
//  factory address: 0xA43b0F8f1aE6bF55843401dd490a92d4959D6cE8

  const configManagerFactory = await ethers.getContractFactory("ConfigManager");
  const configManager = await configManagerFactory.attach("0xd711FcF5AB000Dc88c0Bb64B90Eb60858C0459fD");
  await configManager.deployed();


  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = await factoryManagerFactory.attach("0xA43b0F8f1aE6bF55843401dd490a92d4959D6cE8");
  await factoryManager.deployed();



  //init factory manager key


  var masterDAOKey = "0x7a6e62f9b175c6a7be488b61998eee23ec460b880db24cfaf2109f3cf292c8b3";

  var THE_BOARD_COMMITTEE_KEY = "0xc807c06d810f70a69645cefa8f2245f58499fbf7fac417aee813126af6eac592";

  var THE_PUBLIC_COMMITTEE_KEY = "0xa0f31f21149d1bd033644265f5b4ecaa082df065845083778e64026d759c3238";

  var FACTORY_MANAGER_KEY = "0x5488dc73a58b121c81b942c8a2da9c440f0f5e23c05019dbdc5cf547c661e114";
  // var PROPOSAL_HANDLER_KEY = await configManager.buildConfigKey(admin, "ADMIN", "ProposalHandler");
  var PROPOSAL_HANDLER_KEY = "0x06b5b5544dd0b90f08e17f4f95e64685e4b49e0f950e878aa7bffbf41cafa175";



  var defaultFlowIndex = 0;
  var erc20Address = "0x55d398326f99059ff775485246999027b3197955";
  var stakingAddress = "0x55d398326f99059ff775485246999027b3197955";
  /*
  struct ProposalCommitteeInfo {
      bytes32 step;
      string committeeFactoryID;
      uint256 sensitive;
      string name;
  }
  */

  const theBoardCommitteeDutyIDsBytesArrary: any[] = [keccak256(toUtf8Bytes("PROPOSER_DUTYID"))];

  var theBoardCommitteeDutyIDs = web3.eth.abi.encodeParameter("bytes32[]", theBoardCommitteeDutyIDsBytesArrary);
  // console.log("board duty bytes----:   ", theBoardCommitteeDutyIDs)
  var thePublicCommitteeDutyIDsByteArray:any[] = [keccak256(toUtf8Bytes("VOTER_DUTYID"))];
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
  var flow0Committees: any[] = []
  flow0Committees[0] = ["The Board", keccak256(toUtf8Bytes("board vote")), THE_BOARD_COMMITTEE_KEY, theBoardCommitteeDutyIDs];

  var flow1Committees: any[] = []
  flow1Committees[0] = ["The Public", keccak256(toUtf8Bytes("public vote")), THE_PUBLIC_COMMITTEE_KEY, thePublicCommitteeDutyIDs];
  flow1Committees[1] = ["The Board", keccak256(toUtf8Bytes("board vote")), THE_BOARD_COMMITTEE_KEY, theBoardCommitteeDutyIDs]; 

  var flow2Committees: any[] = []
  flow2Committees[0] = ["The Board", keccak256(toUtf8Bytes("public vote")), THE_PUBLIC_COMMITTEE_KEY, thePublicCommitteeDutyIDs]; 


  var flows: any[] = [];
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
  
  var mds: any[] = [];
  mds[0] = web3.eth.abi.encodeParameters(["string","bytes32", "bytes"], ["content", keccak256(toUtf8Bytes("content1")),"0x00"]);


  var badgeName = "badgeName1";
  var badgeTotal = ethers.utils.parseEther("10000000");
  var daoLogo = "daoDefaultLogo";
  var minPledgeRequired = 10;
  var minEffectiveVotes = 100;
  var minEffectiveVoteWallets = 1;
  var defaultFlowIDIndex = 0;
  var defaultFlowIDIndex = 0;


  var tupleSting = ['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256, bytes32, uint256,' + flowTuple +'[], bytes32)'];
  var tupleData = ["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets, FACTORY_MANAGER_KEY, defaultFlowIDIndex, flows, PROPOSAL_HANDLER_KEY];
  var masterDAOInitialData = defaultAbiCoder.encode(tupleSting,
       [tupleData]);

  console.log(await factoryManager.deploy(true, keccak256(toUtf8Bytes("DAOTypeID")), masterDAOKey,  masterDAOInitialData));
//   console.log(await factoryManager.deploy(false, keccak256(toUtf8Bytes("ProposalHandlerTypeID")), PROPOSAL_HANDLER_KEY,  toUtf8Bytes("")));



  


}



deploy();