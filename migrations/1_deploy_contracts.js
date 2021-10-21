const FlightSuretyData = artifacts.require('FlightSuretyData')
const FlightSuretyApp = artifacts.require('FlightSuretyApp')

module.exports = async deployer => {
  try {
    await deployer.deploy(FlightSuretyData)
    const flightSuretyData = await FlightSuretyData.deployed()
    console.log('flight surety data address: ', flightSuretyData.address)

    await deployer.deploy(FlightSuretyApp, flightSuretyData.address)
    const flightSuretyApp = await FlightSuretyApp.deployed()
    console.log('flight surety app address: ', flightSuretyApp.address)    
  } catch(err) {
    console.log('deploy error:', err )
    
  }
}