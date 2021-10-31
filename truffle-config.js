
const path = require('path')
// const HDWalletProvider = require('@truffle/hdwallet-provider');


module.exports = {
  contracts_build_directory: path.join(__dirname,'/server/abi'),


  networks: {
   
    dev: {
     host: "127.0.0.1",     
     port: 7545,            
     network_id: "*",       
    },
    ganache: {
     host: "127.0.0.1",     
     port: 8545,            
     network_id: "*",      
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
