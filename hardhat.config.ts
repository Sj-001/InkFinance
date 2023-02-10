import { task } from "hardhat/config";
import '@nomiclabs/hardhat-waffle'
import 'dotenv/config'
import 'hardhat-typechain'
import '@nomiclabs/hardhat-ethers'

import 'hardhat-abi-exporter';
import 'hardhat-contract-sizer';
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
        dev_eth: {
            url: process.env.DEV_ETH,
            accounts: [process.env.DEV_ETH_PRIVATE_KEY],
            gasPrice: 10000000070,

        }
        
        
        ,
        dev_avax: {
            url: process.env.DEV_AVAX_RPC,
            accounts: [process.env.DEV_AVAX_KEY]
        }
        ,
        dev_bsc: {
            url: process.env.DEV_BSC_RPC,
            accounts: [process.env.DEV_BSC_KEY]
        }

        ,
        dev_polygon: {
            url: process.env.DEV_POLYGON_RPC,
            accounts: [process.env.DEV_POLYGON_KEY]
        }

        ,
        dev_neon: {
            url: process.env.DEV_NEON_RPC,
            accounts: [process.env.DEV_NEON_KEY]
        }
        ,
        dev_goerli: {
            url: process.env.DEV_GOERLI_RPC,
            accounts: [process.env.DEV_GOERLI_KEY]
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
    },
    contractSizer: {
        alphaSort: true,
        disambiguatePaths: false,
        runOnCompile: true,
        strict: false,
    }


};
