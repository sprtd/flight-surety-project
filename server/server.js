require('dotenv').config()

const express = require('express')
const FlightSuretyData = require('./abi/FlightSuretyData.json')
const FlightSuretyApp = require('./abi/FlightSuretyApp.json')

const { KEY1, KEY2, KEY3, KEY4, KEY5, KEY6, KEY7, KEY8, KEY9, KEY10 } = process.env
const privateKeys = [KEY1, KEY2, KEY3, KEY4, KEY5, KEY6, KEY7, KEY8, KEY9, KEY10 ];

const Web3 = require('web3')


/* Web3 Config ************************ */
const HDWalletProvider = require("@truffle/hdwallet-provider");

// pass an array of private keys
const provider = new HDWalletProvider(privateKeys, "http://localhost:7545", 0, 5); //start at address_index 0 and load both addresses
const web3 = new Web3(provider)

let flightSuretyData, flightSuretyApp, 

const app = express()

const oracleAddresses = []
const oracleMetaData = []


const morgan = require('morgan')
const cors = require('cors')


app.use(cors())
app.use(express.json())
app.use(morgan('dev'))

/* Start Server ************************ */
const startServer = async () => {
  try {
    const accounts = await web3.eth.getAccounts()
    let genAccounts = await web3.eth.getAccounts()
    baseOracle = genAccounts[0]

    /* Network & Contract Config ************************ */
    const networkId = await web3.eth.net.getId()
    const  deployedNetworkData = await FlightSuretyData.networks[networkId]
    const  deployedNetworkApp = await FlightSuretyApp.networks[networkId]
  
    flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, deployedNetworkData && deployedNetworkData.address)
    flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, deployedNetworkApp && deployedNetworkApp.address)
   

    for(i=0; i<accounts.length; i++) {
      oracleAddresses.push(accounts[i])
      if(oracleAddresses.length === accounts.length) {
        return oracleAddresses
      }
    }
   
  } catch(err) {
    console.log(err)
  }
}



/* Register Oracles ************************ */
const registerOracles = async oracles => {
  try {
    const ST_CODES = [0, 10, 20, 30, 40, 50]
    const randomStatusCodes = ST_CODES[Math.floor(Math.random() * ST_CODES.length)]

    let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
    await flightSuretyApp.methods.payOracleRegFees().send({value: oracleFee, from: oracles})
    const indexes = await getOracleIndex(oracles)
    console.log('indexes', indexes)

    oracleMetaData.push({ oracles, indexes, randomStatusCodes})
  } catch(err) {
    console.log(err)
  }
}

/* Get indexes of each oracle ************************ */
const getOracleIndex = async oracles => {
  try {
    const fetchedOracleIndexes = await flightSuretyData.methods.getOracleIndexes().call({from: oracles})
    return fetchedOracleIndexes
  } catch(err) {
    console.log('get oracle error', err)
  }

}

startServer()
  .then(async oraclePayload =>  {

  for(i=0; i < oraclePayload.length; i++) {
    const oracles = oraclePayload[i]

   balance =  await web3.eth.getBalance(oraclePayload[i])
  
   registerOracles(oracles)
   console.log('oracle metadata', oracleMetaData)
    
  }

  })
  .catch(err => console.log('error', err))


const PORT = process.env.PORT
app.listen(PORT, () => console.log(`server running on port ${PORT}`))