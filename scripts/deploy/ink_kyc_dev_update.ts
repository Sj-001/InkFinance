
import '@nomiclabs/hardhat-ethers';
import '@openzeppelin/hardhat-upgrades';
import {Wallet, Contract} from "ethers";
import {MockProvider} from "ethereum-waffle";
import { keccak256, toUtf8Bytes } from 'ethers/lib/utils';

import {ethers, upgrades} from "hardhat";

// when we have previous 

async function deploy(){

  // initial roles
  const signers = await ethers.getSigners();
  // admin
  var admin = signers[0].address;
  console.log("deploy InkFinance Governance Module V2 with this account: ", admin);


  /*
  kycVerifier address: 0x47841638E0F3D6ecd834135F242BE5eC26EC6CD0
  identity address: 0x1257b9a43152d0997C8b5763B1B28164BDF425aA
  */

  const configManagerFactory = await ethers.getContractFactory("KYCVerifyManager");
  const configManager = await configManagerFactory.attach("0x073964c364eC61290812F3Be4D451fD5995067A5");
  await configManager.deployed();
  console.log("KYCVerifyManager deployed..")


  const IdentityFactory = await ethers.getContractFactory("IdentityManager");
  const identityManager = await IdentityFactory.attach("0xE3A4149E1E077f2B4a1baB7374EC4565FC9C543E");
  await identityManager.deployed();

  console.log(await identityManager.getUserKV("INK_FINANCE_KYC", "0xA2FFAe1E83dbda15e4B54CF4f3AD4c377A8B9a84", "account_info"))

  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "SkAdmin", "","0xA2FFAe1E83dbda15e4B54CF4f3AD4c377A8B9a84");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "SkOper", "","0x2b420B81DB05D58E27B0a4aabF6866319136c3B7");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "SkSigner", "","0xdd401f88087d99ce8718Fe65F798AF11D108906a");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "SkAudit", "","0x36a52D80a7A3f8da606652874eA990a7C271e43b");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "SkLiquid", "","0x6012768b1b8F564b3B0268EE7B6971039bf439C5");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Amelia", "","0xa13F3efc184Ab39b7c7f6EC02929791370d06d51");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Mason", "","0x75E114D0c6De025a8073c13d8D0DCb447464e7EF");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Spenser", "","0xdb558948C9d5415d4aE8DE51C28Ab7B1e02eAe70");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Alice1", "","0xE7AE77208402f790340Ee3F9cb91826F5F3a9a48");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Alice2", "","0x65FD6F0eE0e297341EE718917c65d1002eD9cf19");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Alice3", "","0xCa646e72B58A5bb62227E985feB555BfBDA7E088");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Alice4", "","0x28d5c679539d77A5F1b16A93283D5fAb384F768F");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "Alice5", "","0x42c767799f360a110b398618C8534FAC7fF26481");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "sabrina", "","0x90d3Cb2Ac278dAF9d4CAF5AFc0F8ad2c2ceB5Ad6");

  // console.log("50% ")
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "mondi", "","0x2065d2E31B833eCe0fb4E0292280Bb8888C58Ac3");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "sabrina1", "","0x32635F04FfE0815352f6Bc0E08FD2C34446984f5");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "sabrina 2", "","0xBCAf55fc76e6AaB6DCfe989E0262BFd6Be524282");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "sbrinafundDAO", "","0xAb4499deFC24C6dC46b2bd9DB1eB59cf578F849e");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov1", "","0x1F38b3d98cf23A79e210F808dFB8BF40df936E25");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov2", "","0x5F09ce78fbC87CEc2E8c82D848E561F148B2140c");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov3", "","0x5b377BC21d3aDFd18d82dC85C9B6fE3d3209FeCa");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov4", "","0xA324c4f04Acbf7068595B654675F43CD3B1222a5");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov5", "","0xE6CA6490124e1EA62DBFc53Be17fa880372a4D5A");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "tt_gov6", "","0xBb1AF0c0025eB225D05DC921AF02945Af18524FF");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A1", "","0xBbe14Ab2F06Ef9B33DA7da789005b0CD669C7F81");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A6", "","0x6bC990662Cca6A9393D6aee02622E7610b7ef3df");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A7", "","0x25a678Ce9502Bc3827bf3Ba6c65D4977b0E5223b");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A8", "","0x5E6c2625BA3B15A3509417358107b2914cCa9671");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A9", "","0xD5D79Ac91Ee27A323d02Ee44CF099db8A5478DcD");
  // await configManager.verifyUserXYZ("INK_FINANCE_KYC", "twitter", "A11", "","0xf3Ae697E844F30daA76ae2b85c2fd3AcF2489D0e");


  console.log("finished")
  
  

}

deploy();