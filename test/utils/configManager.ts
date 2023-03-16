const { formatEther } = require("@ethersproject/units");
const { expect } = require("chai");
const hardhat = require("hardhat");
import { loadFixture } from 'ethereum-waffle';
import {keccak256, toUtf8Bytes } from 'ethers/lib/utils';
import { ConfigManagerFixture } from '../shared/fixtures'; 
import { waffle, ethers, web3, upgrades } from 'hardhat'
    
describe("utils generate hash", function () {


    /*
    /// 1. domain = wallet public key
    /// 2. key = keccak256(domain + keyID)
    /// 3. keyID = keccak256(keccak256(<prefix>) + keccak256(keyName))
    */

    it("config settings ", async function () {
        const {configManager} = await loadFixture(ConfigManagerFixture);
        const signers = await ethers.getSigners();
        var adminKeys = []

        var keyID = keccak256(toUtf8Bytes(keccak256(toUtf8Bytes("")) + keccak256(toUtf8Bytes("TestKeyName"))));
        adminKeys[0] = {"keyID": keyID, "admin": signers[1].address}
        await configManager.batchSetAdminKeys(adminKeys);

        var adminPrefix = []
        adminPrefix[0] = {"keyPrefix":"ADMIN", "admin":signers[1].address}
        await configManager.batchSetPrefixKeyAdmin(adminPrefix)

        /*
        struct AdminKeyInfo {
            bytes32 keyID;
            address admin;
        }
        struct AdminKeyPrefixInfo {
            string keyPrefix;
            address admin;
        }

        /// @dev KV item
        /// @param keyPrefix prefix of the key
        /// @param keyName key name
        /// @param typeID the key's type
        /// @param data the data of the key
        struct KVInfo {
            string keyPrefix;
            string keyName;
            bytes32 typeID;
            bytes data;
        }        
        */
        var keyValues = [];
        // keyValues[0] = {"keyPrefix":"", "keyName":"TestKeyName", "typeID":keccak256(toUtf8Bytes("ipfs")), "data": toUtf8Bytes("http://www.ipfs/filename")}
        keyValues[0] = {"keyPrefix":"ADMIN", "keyName":"TestKeyName", "typeID":keccak256(toUtf8Bytes("ipfs")), "data": toUtf8Bytes("http://www.ipfs/filename")}
        // await configManager.batchSetKV(signers[0].address, keyValues);
        await configManager.connect(signers[1]).batchSetKV(signers[0].address, keyValues);

        // var key = await configManager.buildConfigKey(signers[0].address, "", "TestKeyName");
        var key = await configManager.buildConfigKey(signers[0].address, "ADMIN", "TestKeyName");
        console.log("key value:", await configManager.getKV(key));

    });
    



})