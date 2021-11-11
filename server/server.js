require('dotenv').config()
const express = require('express')

const { connectDB } = require('./models/config/db.config')

const FlightSuretyData = require('../client/src/abi/FlightSuretyData.json')
const FlightSuretyApp = require('../client/src/abi/FlightSuretyApp.json')
const Web3 = require('web3')
const BN = require('bignumber.js')
connectDB()

const { PORT } = process.env
const Oracle = require('./models/oracle-model')

/* Web3 Config ************************ */
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:7545'))


let flightSuretyData, flightSuretyApp, accounts, indexes, newJSONData

const loopedOracleArray = []

/* Register Oracles ************************ */
const registerOracles = async (oracles) => {
  try {
    const ST_CODES = [0, 10, 20, 30, 40, 50]
    const randomStatusCodes = ST_CODES[Math.floor(Math.random() * ST_CODES.length)]
    
    let oracleFee = await flightSuretyApp.methods.ORACLE_REGISTRATION_FEE().call()
    await flightSuretyApp.methods.payOracleRegFees().send({ value: oracleFee, from: oracles, gas: 3000000 })
    indexes = await getOracleIndex(oracles)
    if(indexes.length) {
      const saveOracle = async () => {
        try {
          const newOracle = new Oracle({
            oracles, 
            indexes, 
            statusCodes: randomStatusCodes

          })
          await newOracle.save()

        } catch(err) {
          console.log('err', err)
        }
      }

      saveOracle()  
    }
    
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

/* Get respective metadata of each saved oracle ************************ */
const getOracleMetaData = async () => {
  try {
    const oracleResult = await Oracle.find({}).exec()
    // console.log('oracle retrieved', oracleResult)

    return oracleResult

  } catch(err) {

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
  

    // Events
    let eventOptions = {
      filter: {
        value: []
      }, 
      fromBlock: 0,
    }


    // Watch Oracle Registration  Event
    flightSuretyData.events.LogFlightRegistered(eventOptions)
      .on('data', event => {
          const { returnValues: { name, flightKey, airline, timestamp, statusCode} } = event
          console.log({ name })
          console.log({airline})
          console.log({timestamp})
          console.log({statusCode})
          console.log({flightKey})

      })
      .on('error', err => console.log('err' , err))
      .on('connected', str => console.log(str))

    // Watch Fetch FlightStatus Event
    flightSuretyData.events.LogOracleRequest(eventOptions)
      .on('data', event => {
        console.log('log oracle request events', event.returnValues)
        const { returnValues: { index, airline, flight: flightName, timestamp }} = event        
        const delegateOracles = []

        const checkOracleResult = async () => {
          try {
            const fetchedOracles = await getOracleMetaData()
            // console.log('fetched oracles', fetchedOracles)
            if(fetchedOracles.length) {
              fetchedOracles.forEach(({oracles, indexes, statusCodes}) =>  {
               

                // select oracle delegates whose index matches flight status request
                if(BN(indexes[0]).isEqualTo(index) || BN(indexes[1]).isEqualTo(index) || BN(indexes[2]).isEqualTo(index)) {

                  delegateOracles.push(oracles)

                  if(delegateOracles.length >= 3) {
                    // console.log('delegated oracles', delegateOracles)
                  
                    for(i=0;i<delegateOracles.length;i++) {
                      // console.log('delegate oracles', delegateOracles[i])
                      const reportingOracles = delegateOracles[i]

                      const submit = async () => {
                        try {
                          await flightSuretyData.methods.submitOracleResponse(index, airline, timestamp, statusCodes).send({from: reportingOracles, gas: 4750000 })
  
                        } catch(err) {
                          console.log('oracle submission error', err)
                        }

                      }

                     submit()
                     
                    }

                  }
                }
              })
            }

          } catch(err) {
            console.log('fetch oracle error', err)
          }
        }

        checkOracleResult()    
      })
      .on('error', err => console.log('err' , err))


    // Watch Processed Flight Status
    flightSuretyData.events.LogFlightStatusProcessed(eventOptions)
      .on('data', event => {
        console.log('log flight status processed', event.returnValues)
      })
      .on('error', err => console.log('err' , err))

         
    const isOracleRegisteredBefore = await flightSuretyData.methods.isOracleRegistered(accounts[20]).call()
    console.log('oracle registration status before', isOracleRegisteredBefore)
    
    if(!isOracleRegisteredBefore) {     
      for(i=20; i < accounts.length; i++) {
        await registerOracles(accounts[i])
        console.log(accounts[i])

      }     
    }

  } catch(err) {
    console.log(err)
  }
}

startServer()
const app = express()
app.listen(PORT, () => console.log(`server running on port: ${PORT}`))





