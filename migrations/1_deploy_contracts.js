const FlightSuretyData = artifacts.require('FlightSuretyData')
const FlightSuretyApp = artifacts.require('FlightSuretyApp')

module.exports = async deployer => {
  try {
    deployer.deploy(FlightSuretyData)
    const flightSuretyData = FlightSuretyData.deployed()
    console.log('flight surety data address: ', flightSuretyData.address)

    deployer.deploy(FlightSuretyApp, flightSuretyData.address)
    const flightSuretyApp = FlightSuretyApp.deployed()
    console.log('flight surety app address: ', flightSuretyApp.address)

    

    console.log()
    
  } catch(err) {
    console.log('deploy error: ', err )
    
  }
}