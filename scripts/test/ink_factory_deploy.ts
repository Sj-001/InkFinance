
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




  const factoryManagerFactory = await ethers.getContractFactory("FactoryManager");
  const factoryManager = await factoryManagerFactory.attach("0x28be5Cd903Bcc3BeedA2eC8B25450E0A3eaa61E9");

  var PROPOSAL_HANDLER_KEY = "0x06b5b5544dd0b90f08e17f4f95e64685e4b49e0f950e878aa7bffbf41cafa175";


  // console.log(await factoryManager.deploy(true, keccak256(toUtf8Bytes("DAOTypeID")), masterDAOKey,  masterDAOInitialData));
  console.log(await factoryManager.deploy(false, keccak256(toUtf8Bytes("ProposalHandlerTypeID")), PROPOSAL_HANDLER_KEY,  toUtf8Bytes("")));



  


}



deploy();