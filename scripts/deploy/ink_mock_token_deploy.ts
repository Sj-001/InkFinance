
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

import {ethers, upgrades} from "hardhat";

// constant define

async function deploy(){

  const [owner] = await ethers.getSigners();
  console.log("start deploy");

  const demoTok1Factory = await ethers.getContractFactory("MockERC20");
  const demo_tok1 = await demoTok1Factory.deploy("AVAX_TOK1", "AVAX_TOK1");
  await demo_tok1.deployed();
  // const demo_tok1 = await hre.ethers.getContractAt("InkERC20", "0x9bC5A13fA6B17aB2805FFB3709dAe0237A34cF7B")
  await demo_tok1.mintTo(owner.address, '100000000000000000000000000000000');
  console.log("AVAX_tok1=", demo_tok1.address);

  const demoTok2Factory = await ethers.getContractFactory("MockERC20");
  const demo_tok2 = await demoTok2Factory.deploy("AVAX_TOK2", "AVAX_TOK2");
  await demo_tok2.deployed();
  // const demo_tok2 = await hre.ethers.getContractAt("InkERC20", "0xa1F1C37A9980af260767934515f6B21dB2Dd0D98")
  await demo_tok2.mintTo(owner.address, '100000000000000000000000000000000')
  console.log("AVAX_tok2=", demo_tok2.address);




}

deploy();