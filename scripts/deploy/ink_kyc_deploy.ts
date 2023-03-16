
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
  console.log("deploy InkFinance Governance Module V2 with this account: ", admin);


  const kycFactory = await ethers.getContractFactory("KYCVerifyManager");
  const kycVerifier = await kycFactory.deploy("0xf46B1E93aF2Bf497b07726108A539B478B31e64C");
  await kycVerifier.deployed();
  console.log("kycVerifier deployed..")

  const identityManagerFactory = await ethers.getContractFactory("IdentityManager");
  const identity = await identityManagerFactory.deploy(kycVerifier.address);
  await identity.deployed();

  await kycVerifier.updateIdentityManager(await identity.address);

  console.log("kycVerifier address:", kycVerifier.address);
  console.log("identity address:", identity.address);

}

deploy();