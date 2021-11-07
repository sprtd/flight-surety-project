require('dotenv').config({ path: './config/config.env'})
const path = require('path')
const HDWalletProvider = require('@truffle/hdwallet-provider');




module.exports = {
  contracts_build_directory: path.join(__dirname,'/client/src/abi'),


  networks: {
   
    dev: {
      host: "127.0.0.1",     
      port: 7545,            
      network_id: "*",   

    },
    ganache: {
      networkCheckTimeout: 1000000, 
      host: "127.0.0.1",     
      port: 8545,            
      network_id: "*",   
    },
    rinkeby: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.MNEMONIC,
        providerOrUrl: process.env.RINKEBY_ENDPOINT
      }),
      network_id: 4,   
      networkCheckTimeout: 999999,
    },
   
   
  },

  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8.0",   
      settings: {          
       optimizer: {
         enabled: false,
         runs: 200
       },
      //  evmVersion: "byzantium"
      }
    }
  },


  plugins: [
    'truffle-contract-size'
  ]
};
