
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

import {ethers, upgrades} from "hardhat";

// constant define

async function deploy(){

  // initial roles
  const signers = await ethers.getSigners();
  // admin
  var admin = signers[0].address;
  console.log("deploy InkFinance Governance Module Mock NFT with this account: ", admin);

  const mockNFTFactory = await ethers.getContractFactory("MockNFT");
  const mockNFT = await mockNFTFactory.deploy();
  await mockNFT.deployed();

;
  console.log("Mock NFT address:", mockNFT.address);
  
 
  console.log("");




}

deploy();