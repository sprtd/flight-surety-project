const FlightSuretyData = artifacts.require('FlightSuretyData')
const FlightSuretyApp = artifacts.require('FlightSuretyApp')

const { toWei } = require('../utils/conversion')

module.exports = async (deployer, accounts) => {
  try {
    await deployer.deploy(FlightSuretyData)
    const flightSuretyData = await FlightSuretyData.deployed()
    console.log('flight surety data address: ', flightSuretyData.address)

    await deployer.deploy(FlightSuretyApp, flightSuretyData.address)
    const flightSuretyApp = await FlightSuretyApp.deployed()
    console.log('flight surety app address: ', flightSuretyApp.address)    



    // await flightSuretyApp.payCommitmentFee({value: toWei(10), from: accounts[0]})

    // await flightSuretyApp.registerFlight(10, {from: addr2})




  } catch(err) {
    console.log('deploy error:', err )
    
  }
}