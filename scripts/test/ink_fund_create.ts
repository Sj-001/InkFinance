
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
  var dao = await df.attach("0xa662ed6325dAeFf7f73E0Fc1F63F1624A22D37D8");


  console.log(await dao.address);
  var FUND_MANAGER_KEY = "0x4af27e0d765a920550ab023933b03f6a15e7d1baafae12f47283dd2df7a77d97";
  var fundManagerAddress = await dao.getDeployedContractByKey(FUND_MANAGER_KEY);

  var percentage2 = ethers.utils.parseEther("0.02");


    var fundName = "Fundname";
    var fundDescription = "FundDescription";
    var fundToken = "0xa662ed6325dAeFf7f73E0Fc1F63F1624A22D37D8";
    var minRaise = ethers.utils.parseEther("1000");
    var maxRaise = ethers.utils.parseEther("10000");

    var timestamp = Date.now();
    var sec = Math.floor(timestamp / 1000);

    var raisedPeriod = 60 * 60 * 24 * 5; // 5 days
    var durationOfFund = 60 * 60 * 24 * 30;

    var allowIntermittentDistributions = 1;
    var allowFundTokenized = 1;
    var tokenName = "TestTokenName";
    var tokenAmount = ethers.utils.parseEther("10000");

    var allowExchange = 1;
    var auditPeriod = 60 * 60 * 24;

    var investmentDomain = 1; // real-world
    var investmentType = 1; // Debt/Loans/Bonds

    var maxSingleExposure = 100;
    var minNumberOfHoldings = 1;
    var maxNavDowndraftFromPeak = 5;
    var maxNavLoss = 20;

    var requireClientBiometricIdentity = 0;
    var requireClientLegalIdentity = 0;

    

    var fixedFee = percentage2;
    var fixedFeeShouldGoToTreasury = 1;

    var performanceFee = percentage2;
    var performanceFeeShouldGoToTreasury = 1;
    
    var fundManager = admin;

    var fundManagers = [admin];
    // fundManagers[0] = admin;

    var riskManagers = [admin];
    // riskManagers[0] = admin;


    var fundManagerFactory = await ethers.getContractFactory("FundManager");
    var fundManagerContract = await fundManagerFactory.attach(fundManagerAddress);

    var fundInitialData = {
        "fundDeployKey": "0x5e6a8c18c8f81f6b58d99b351ef8f80e717e1bca5b7663792655bb4cfd073b02",
        "fundName" : fundName,
        "fundDescription" : fundDescription,
        "fundToken": fundToken, 
        "minRaise" : minRaise,
        "maxRaise" : maxRaise,
        "raisedPeriod" : raisedPeriod,
        "durationOfFund" : durationOfFund,
        "allowIntermittentDistributions" : allowIntermittentDistributions,
        "allowFundTokenized" : allowFundTokenized,
        "tokenName" : tokenName,
        "allowExchange" : allowExchange,
        "auditPeriod" : auditPeriod,
        "investmentDomain" : investmentDomain,
        "investmentType" : investmentType,
        "maxSingleExposure" : maxSingleExposure,
        "minNumberOfHoldings" : minNumberOfHoldings,
        "maxNavDowndraftFromPeak" : maxNavDowndraftFromPeak,
        "maxNavLoss" : maxNavLoss,
        "requireClientBiometricIdentity" : requireClientBiometricIdentity,
        "requireClientLegalIdentity" : requireClientLegalIdentity,
        "fixedFee" : fixedFee,
        "fixedFeeShouldGoToTreasury" : fixedFeeShouldGoToTreasury,
        "performanceFee" : performanceFee,
        "performanceFeeShouldGoToTreasury" : performanceFeeShouldGoToTreasury,
        "fundManagers" : fundManagers,
        "riskManagers" : riskManagers
    }

    await fundManagerContract.createFund(fundInitialData);


    


}



deploy();