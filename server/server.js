require('dotenv').config()

const express = require('express')

const FlightSuretyData = require('../client/src/abi/FlightSuretyData.json')
const FlightSuretyApp = require('../client/src/abi/FlightSuretyApp.json')
const Web3 = require('web3')

const { PORT } = process.env

/* Web3 Config ************************ */
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:7545'))



let accounts

let flightSuretyData, flightSuretyApp, indexes

const oracleMetaData = []


const { toWei, fromWei } = require('../utils/conversion')


/* Register Oracles ************************ */
const registerOracles = async (oracles) => {
  try {
    const ST_CODES = [0, 10, 20, 30, 40, 50]
    const randomStatusCodes = ST_CODES[Math.floor(Math.random() * ST_CODES.length)]
    
    let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
    await flightSuretyApp.methods.payOracleRegFees().send({value: oracleFee, from: oracles })
    indexes = await getOracleIndex(oracles)
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


/* Start Server ************************ */
const startServer = async () => {
  try {
    
    /* Network & Contract Config ************************ */
    const networkId = await web3.eth.net.getId()
    const  deployedNetworkData = await FlightSuretyData.networks[networkId]
    const  deployedNetworkApp = await FlightSuretyApp.networks[networkId]
    
    flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, deployedNetworkData && deployedNetworkData.address)
    flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, deployedNetworkApp && deployedNetworkApp.address)
    
    accounts = await web3.eth.getAccounts()

    
    let eventOptions = {
      filter: {
        value: []
      }, 
      fromBlock: 0,
    }
    
    flightSuretyData.events.LogFlightRegistered(eventOptions)
    .on('data', event => {
        const { returnValues: { flightKey, airline, timestamp, statusCode} } = event
      console.log()
      console.log('airline', airline)
      console.log('timestamp', timestamp)
      console.log('statusCode', statusCode)
    })
    .on('changed', changed => console.log(changed))
    .on('error', err => console.log('err' , err))
    .on('connected', str => console.log(str))
    const executeReOracle = async() => {
          
      const isOracleRegisteredBefore = await flightSuretyData.methods.isOracleRegistered(accounts[20]).call()
      console.log('oracle registration status', isOracleRegisteredBefore)
      
      let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
      if(isOracleRegisteredBefore === false) {
        console.log('oracle fee', fromWei(oracleFee))
        console.log('length fetched',accounts.length)
        
      
        try {
          const ST_CODES = [0, 10, 20, 30, 40, 50]
          const randomStatusCodes = ST_CODES[Math.floor(Math.random() * ST_CODES.length)]
          const oracleAccount = accounts[20]
          
          // registerOracles(oracleAccount)
      
          // let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
          // await flightSuretyApp.methods.payOracleRegFees().send({ value: oracleFee, from: oracleAccount })
          // indexes = await getOracleIndex(oracleAccount)
          // oracleMetaData.push({oracleAccount, indexes, randomStatusCodes})
          
        } catch(err) {
          console.log(err)
        }
      }

    }

    executeReOracle()
    
    
    
  } catch(err) {
    console.log(err)
  }
}

startServer()
const app = express()
app.listen(PORT, () => console.log(`server running on port: ${PORT}`))

// module.exports = app




