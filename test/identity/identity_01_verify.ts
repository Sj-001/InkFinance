
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { ConfigManager } from '../../typechain/ConfigManager'
import { FactoryManagerFixture, InkERC20Fixture, KYCVerifyFixture } from '../shared/fixtures'; 

import { PROPOSAL_HANDLER_KEY,INK_CONFIG_DOMAIN, FACTORY_MANAGER_KEY, MASTER_DAO_KEY, THE_BOARD_COMMITTEE_KEY, THE_PUBLIC_COMMITTEE_KEY, THE_TREASURY_COMMITTEE_KEY } from '../shared/fixtures'; 
import { FactoryTypeID, DAOTypeID, AgentTypeID, CommitteeTypeID } from '../shared/fixtures'; 

import { PROPOSER_DUTYID, VOTER_DUTYID } from '../shared/fixtures'; 
import { buildMasterDAOInitData } from '../shared/parameters'; 


import {defaultAbiCoder} from '@ethersproject/abi';
import { expect } from "chai";

// const {
    0x7a6e62f9b175c6a7be488b61998eee23ec460b880db24cfaf2109f3cf292c8b3

//     pack,
//     keccak256,
//     sha256

// } = require("@ethersproject/solidity");

const {loadFixture, deployContract} = waffle;

describe("identity test", function () {

    it("test create master dao", async function () {

        const signers = await ethers.getSigners();
        const {verifier} = await loadFixture(KYCVerifyFixture); 
        
        const buyer1 = signers[0];
        // var sign1 = "0x82382ca884db8f0239240aaa1c4596d55e6c9585fb4cc51bdcea069baaefe71364eacea15c9f51793a5a36f8d25edee434f67df78bca1d9bbb28d72411bce8b41b";
        // var type1 = "twitter"
        // var accountID1 = "A1"
        // var wallet = "0xBbe14Ab2F06Ef9B33DA7da789005b0CD669C7F81";
        // await verifier.verifyUser(sign1, "", type1, accountID1, "");
        


        
        var sign = "0xc39a9ea67bb29fd18d4241651fc5bcdf4732b3633a8c7ab6f4af7f04efdca4c41e601c1100da058baf3f86dc1fd23357cf85b15629ca31d9a80d41652817f78f1c";
        var zone = "INK_FINANCE_KYC"
        var type = "twitter"
        var accountID = "T1"
        var data = ""
        var wallet = "0x779a3944CFbFB32038726307E48658719efaC02f"


        await verifier.verifyUser(sign, zone, type, accountID, data);

        const identity = await ethers.getContractAt("IIdentity", await verifier.getIdentityManager());

        console.log("returned", await identity.getUserKV(verifier.address, wallet, "account_info"))

    });

})