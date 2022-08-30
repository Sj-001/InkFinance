import { task } from "hardhat/config";
import '@nomiclabs/hardhat-waffle'
import 'dotenv/config'
import 'hardhat-typechain'
import '@nomiclabs/hardhat-ethers'

import 'hardhat-abi-exporter';

import "@nomiclabs/hardhat-web3";
import '@openzeppelin/hardhat-upgrades';


module.exports = {
    mocha: {
        timeout: 1000000
    },
    solidity: {
        version: "0.8.4",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },

    networks: {
        dev: {
            url: `https://gethdev.inkfinance.xyz`,
            accounts: ["ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"],
                // mnemonic: `test test test test test test test test test test test junk`,
                // private key: ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
            // },
            gasPrice: 10000000070,

        },
        rinkeby: {
            url: process.env.API_URL_RINKEBY,
            accounts: [process.env.PRIVATE_KEY_RINKEBY]
        }
      
    },

    abiExporter: {
        path: './abi',
        runOnCompile: true,
        clear: true,
        flat: true,
        only: [],
        spacing: 2,
        pretty: false
    }


};
