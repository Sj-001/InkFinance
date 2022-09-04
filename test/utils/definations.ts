const { formatEther } = require("@ethersproject/units");
const { expect } = require("chai");
const hardhat = require("hardhat");
import { loadFixture } from 'ethereum-waffle';
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';

describe("utils generate hash", function () {


    it("ink finance roles", async function () {
        console.log("inkfinance.xyz:ADMIN", keccak256(toUtf8Bytes("inkfinance.xyz:ADMIN")))



    });

    it("ink finance duty ids", async function () {
        console.log("INK_FINANCE_UCV_MANAGER: ", keccak256(toUtf8Bytes("INK_FINANCE_UCV_MANAGER")))
        


    });




    

})