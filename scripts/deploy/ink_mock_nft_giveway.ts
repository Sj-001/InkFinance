
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

  // await mockNFT.mint("0xA2FFAe1E83dbda15e4B54CF4f3AD4c377A8B9a84", 10);
  // await mockNFT.mint("0x2065d2E31B833eCe0fb4E0292280Bb8888C58Ac3", 10);
  // await mockNFT.mint("0xAfB22f50eA0819385De7ee2436b66484b34E74Fc", 10);
  await mockNFT.mint("0xfb6D5E939CC21fE271245Fa2963F427C665035A3", 10);
  
 
  console.log("");




}

deploy();