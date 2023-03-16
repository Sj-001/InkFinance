
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

    var df = await ethers.getContractFactory("MasterDAO");
    var dao = await df.attach("0x49D762438ED0D72FFBEE55cE1A7B24d20E3175D8");
    console.log(await dao.address);

    var fundManagerFactory = await ethers.getContractFactory("FundManager");
    // var fundManagerContract = await fundManagerFactory.deploy();
    var fundManagerContract = await fundManagerFactory.attach("0x7EF848eCd71d6722847633dE655575BB55c78d4F");

    // await fundManagerContract.deployed();
    // await fundManagerContract.testInit(dao.address, "0xb33948b0774868c97E76E9d75E0a42Ef9f553DCA");


    // var inkFundFactory = await ethers.getContractFactory("InkFund");

    // var inkFundImpl = await inkFundFactory.deploy();

    // await inkFundImpl.deployed();


    // /// init template
    // var keyValues : any = [];
    // keyValues[0] = {"keyPrefix":"ADMIN", "keyName":"InkFund", "typeID":keccak256(toUtf8Bytes("address")), "data": (await inkFundImpl.address)}
    
    // const configManagerFactory = await ethers.getContractFactory("ConfigManager");
    // const configManager = await configManagerFactory.attach("0x03C1a34fF9aaE0adB53A365Ca5559D596b50700D");

    // await configManager.batchSetKV(admin, keyValues);


    var fundInitialData = {
      "fundDeployKey": "0x5e6a8c18c8f81f6b58d99b351ef8f80e717e1bca5b7663792655bb4cfd073b02",
      "fundName": "Fund1",
      "fundDescription": "Fund1 desc",
      "fundToken": "0x472855642DD7E9baDfAEe05F3bAf0D8267F988A8",
      "minRaise": "100000000000000000000",
      "maxRaise": "200000000000000000000",
      "raisedPeriod": "600",
      "durationOfFund": "600",
      "allowIntermittentDistributions": "0",
      "allowFundTokenized": "1",
      "tokenName": "tUSDT",
      "allowExchange": "0",
      "auditPeriod": "300",
      "investmentDomain": 0,
      "investmentType": 0,
      "maxSingleExposure": "10000000000000000000",
      "minNumberOfHoldings": "20000000000000000000",
      "maxNavDowndraftFromPeak": "30000000000000000000",
      "maxNavLoss": "40000000000000000000",
      "requireClientBiometricIdentity": "0",
      "requireClientLegalIdentity": "0",
      "fixedFee": "10000000000000000000",
      "fixedFeeShouldGoToTreasury": "0",
      "performanceFee": "20000000000000000000",
      "performanceFeeShouldGoToTreasury": "0",
      "fundManagers": [],
      "riskManagers": []
  }

  console.log(await fundManagerContract.createFund(fundInitialData));


    


}



deploy();