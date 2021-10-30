

// const HDWalletProvider = require('@truffle/hdwallet-provider');


module.exports = {


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

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows: 
  // $ truffle migrate --reset --compile-all
  //
  // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
  // }
};
