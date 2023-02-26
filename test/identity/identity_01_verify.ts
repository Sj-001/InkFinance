
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
        

        var sign = "0x82382ca884db8f0239240aaa1c4596d55e6c9585fb4cc51bdcea069baaefe71364eacea15c9f51793a5a36f8d25edee434f67df78bca1d9bbb28d72411bce8b41b";
        var type = "twitter"
        var accountID = "A1"
        // var eoa = ""

        await verifier.registerUser(sign, type, accountID);
        
    });

})