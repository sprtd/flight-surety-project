
const FlightSuretyData = artifacts.require('FlightSuretyData')


const truffleAssert = require('truffle-assertions')
let flightSuretyData,  deployer, addr1, addr2, addr3, addr4



contract('Data Contract', async payloadAccounts => {

  deployer = payloadAccounts[0]
  addr1 = payloadAccounts[1]
  addr2 = payloadAccounts[2]
  addr3 = payloadAccounts[3]
  addr4 = payloadAccounts[4]


  beforeEach(async() => {
    flightSuretyData = await FlightSuretyData.deployed()
  })

  contract('Deployment', () => {
   

  })

  

})