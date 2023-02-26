import { expect } from "chai";
import { ethers, network } from "hardhat";
import { Contract, Signer } from "ethers";
import hre from "hardhat";

import { getEthersSigners } from "../scripts/helpers/contracts-helpers";

before(async () => {
  const [deployer, daoOwner, operator, signer1, signer2, auditor ] = await getEthersSigners();
  console.log('-> Deploying test environment...');




});
