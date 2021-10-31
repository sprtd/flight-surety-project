require('dotenv').config()

const express = require('express')
const FlightSuretyData = require('./abi/FlightSuretyData.json')
const FlightSuretyApp = require('./abi/FlightSuretyApp.json')

const { KEY1, KEY2, KEY3, KEY4, KEY5 } = process.env
const privateKeys = [KEY1, KEY2, KEY3, KEY4, KEY5];

const Web3 = require('web3')


/* Web3 Config ************************ */

const HDWalletProvider = require("@truffle/hdwallet-provider");

// pass an array of private keys
const provider = new HDWalletProvider(privateKeys, "http://localhost:7545", 0, 5); //start at address_index 0 and load both addresses
const web3 = new Web3(provider)

let flightSuretyData, flightSuretyApp

const app = express()

const oracleAddresses = []


const morgan = require('morgan')
const cors = require('cors')


app.use(cors())
app.use(express.json())
app.use(morgan('dev'))


const startServer = async () => {
  try {
    const accounts = await web3.eth.getAccounts()

    /* Network & Contract Config ************************ */
    const networkId = await web3.eth.net.getId()
    const  deployedNetworkData = await FlightSuretyData.networks[networkId]
    const  deployedNetworkApp = await FlightSuretyApp.networks[networkId]
  
    flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, deployedNetworkData && deployedNetworkData.address)
    flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, deployedNetworkApp && deployedNetworkApp.address)
   
    console.log('data address', deployedNetworkData.address)
    console.log('app address', deployedNetworkApp.address)

    registerOracles()

    for(i=0; i<accounts.length; i++) {
      oracleAddresses.push(accounts[i])
      if(oracleAddresses.length === 5) {
        return oracleAddresses
      }
    }
   
  } catch(err) {
    console.log(err)
  }
}


const registerOracles = async () => {
  try {
    let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
    oracleFee = oracleFee.toString()
    console.log({oracleFee})

  } catch(err) {
    console.log(err)
  }
 

}


startServer().then(res =>  {
  console.log(res)
})


const PORT = process.env.PORT
app.listen(PORT, () => console.log(`server running on port ${PORT}`))