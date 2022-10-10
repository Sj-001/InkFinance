import hre from "hardhat";
import { Contract, Signer, utils, ethers, BigNumberish } from 'ethers';

export const getEthersSigners = async (): Promise<Signer[]> => {
  const ethersSigners = await Promise.all(await hre.ethers.getSigners());
  return ethersSigners;
};
