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
        ink_dev_eth: {
            url: process.env.INK_DEV_ETH,
            accounts: [process.env.INK_DEV_ETH_PRIVATE_KEY],
            gasPrice: 10000000070,

        }
        
        // ,
        // rinkeby: {
        //     url: process.env.API_URL_RINKEBY,
        //     accounts: [process.env.PRIVATE_KEY_RINKEBY]
        // }
      
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
