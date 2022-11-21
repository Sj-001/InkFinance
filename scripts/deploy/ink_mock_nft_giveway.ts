
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
  const mockNFT = await mockNFTFactory.attach("0x0eCdabdc97Bc5E8b4BfB0630283B1C2F454194bc");

  await mockNFT.mint("", 3);
  
 
  console.log("");




}

deploy();