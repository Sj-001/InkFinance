
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { GlobalConfig } from '../../typechain/GlobalConfig'
import { FactoryManagerFixture, InkERC20Fixture } from '../shared/fixtures'; 

import { masterDAO_ContractID } from '../shared/fixtures'; 
import { defaultProposer_DutyID } from '../shared/fixtures'; 

import {defaultAbiCoder} from '@ethersproject/abi';

// const {

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("contract dao test", function () {


    it("test create dao", async function () {
        
        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        const {inkERC20} = await loadFixture(InkERC20Fixture);
        
        var erc20Address = inkERC20.address;

        /*
        console.log("erc address:", erc.address);
        var baseInitData = web3.eth.abi.encodeParameter("string", "content");
        var vaultInitData = web3.eth.abi.encodeParameters(["uint256","uint256","uint256","uint256","uint256","uint256"], [1,2,3,4,5,6]);
        var initData = web3.eth.abi.encodeParameters(["bytes", "bytes", "address", "uint256"], [baseInitData, vaultInitData, erc.address, 100]);
        */

        /* MasterDAOInitData
        string name;
        string describe;
        bytes[] mds;
        IERC20 govTokenAddr;
        uint256 govTokenAmountRequirement;
        address stakingAddr;
        FlowInfo[] flows;
        string badgeName;
        uint256 badgeTotal;
        string daoLogo;
        uint256 minPledgeRequired;
        uint256 minEffectiveVotes;
        uint256 minEffectiveVoteWallets;
        */
        // var masterDAOFlowData = web3.eth.abi.encodeParameters(["uint256","uint256","uint256","uint256","uint256","uint256"], [1,2,3,4,5,6]);
        var stakingAddress = erc20Address;

        var mds = [];
        
        
        mds[0] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content1"));
        mds[1] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content2"));
        mds[2] = web3.eth.abi.encodeParameter("bytes", toUtf8Bytes("content3"));

        // var masterDAOInitialData =
        //      web3.eth.abi.encodeParameters(["string","string", "bytes[]","address","uint256","address"], ["daoName","daoDescribe",mds, erc20Address, 100000, erc20Address]);
        // var masterDAOInitialData =
        //      web3.eth.abi.encodeParameters(["string","string"], ["daoName","daoDescribe"]);

        var badgeName = "badgeName1";
        var badgeTotal = 100;
        var daoLogo = "daoDefaultLogo";
        var minPledgeRequired = 10;
        var minEffectiveVotes = 100;
        var minEffectiveVoteWallets = 1;



        var masterDAOInitialData = defaultAbiCoder.encode(['tuple(string, string, bytes[], address, uint256, address, string, uint256, string, uint256, uint256, uint256)'],
             [["daoName","daoDescribe", mds, erc20Address, 100000, erc20Address, badgeName, badgeTotal, daoLogo, minPledgeRequired, minEffectiveVotes, minEffectiveVoteWallets]]);
        await factoryManager.deploy(masterDAO_ContractID, masterDAOInitialData);


        // var firstDAOAddress = await factoryManager.getDeployedAddress(masterDAO_ContractID, 0);
        // console.log("first dao address:", firstDAOAddress);

        // var masterDAO = await ethers.getContractFactory("MasterDAO");
        // var contract = masterDAO.attach(firstDAOAddress);


        // var encodedByte = await contract.buildInitData(masterDAOInitInfo);

        // await contract.testDecode(encodedByte);



    });





    


    

})