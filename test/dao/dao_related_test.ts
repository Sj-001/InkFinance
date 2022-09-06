
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { Fixture } from 'ethereum-waffle'
import { waffle, ethers, web3, upgrades } from 'hardhat'
import { FactoryManager } from '../../typechain/FactoryManager'
import { GlobalConfig } from '../../typechain/GlobalConfig'
import { FactoryManagerFixture } from '../shared/fixtures'; 

import { masterDAO_ContractID } from '../shared/fixtures'; 
import { defaultProposer_DutyID } from '../shared/fixtures'; 



const {loadFixture, deployContract} = waffle;

describe("contract dao test", function () {


    it("test create dao", async function () {
        
        const {factoryManager} = await loadFixture(FactoryManagerFixture);
        await factoryManager.deploy(masterDAO_ContractID, toUtf8Bytes(""))
        var firstDAOAddress = await factoryManager.getDeployedAddress(masterDAO_ContractID, 0);
        console.log("first dao address:", firstDAOAddress);

    });



    


    

})