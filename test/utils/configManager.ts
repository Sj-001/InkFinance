const { formatEther } = require("@ethersproject/units");
const { expect } = require("chai");
const hardhat = require("hardhat");
import { loadFixture } from 'ethereum-waffle';
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { ConfigManagerFixture } from '../shared/fixtures'; 

describe("utils generate hash", function () {




    it("config settings ", async function () {
        const {configManager} = await loadFixture(ConfigManagerFixture);
        // console.log(await configManager.getKV(toUtf8Bytes("keys")));

    });
    



})