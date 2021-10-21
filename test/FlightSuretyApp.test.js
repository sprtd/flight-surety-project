
const FlightSuretyData = artifacts.require('FlightSuretyData')
const FlightSuretyApp = artifacts.require('FlightSuretyApp')


// const truffleAssert = require('truffle-assertions')
let flightSuretyApp, flightSuretyData, deployer, addr1, addr2, addr3, addr4, addr5, airlineName, id, state, airlines





contract('FlightSuretyApp', async payloadAccounts => {



  deployer = payloadAccounts[0]
  addr1 = payloadAccounts[1]
  addr2 = payloadAccounts[2]
  addr3 = payloadAccounts[3]
  addr4 = payloadAccounts[4]
  addr5 = payloadAccounts[5]



  airlines = {
    addr1: payloadAccounts[1],
    addr2: payloadAccounts[2],
    addr3: payloadAccounts[3],
    addr4: payloadAccounts[4],
    addr5: payloadAccounts[5],
    // addr6: payloadAccounts[6]

  }


  


  

  beforeEach(async() => {
    flightSuretyData = await FlightSuretyData.new()
    flightSuretyApp = await FlightSuretyApp.new(flightSuretyData.address)

    airlineName = {
      airline1: 'alpha1',
      airline2: 'alpha2',
      airline3: 'alpha3',
      airline4: 'alpha4',
      airline5: 'alpha5',
      // airline6: 'alpha6',
    }
    
    id = {
      airline1: 1,
      airline2: 2,
      airline3: 3,
      airline4: 4,
      airline5: 5,
      airline6: 6
    }

    state = {
      Applied: 'Applied',
      Registered: 'Registered',
      Committed: 'Committed'
    }
  
  })

  contract('Deployment', () => {
    it('Should allow deployer address to apply and register  as airline upon deployment', async () => {
  
      const ownerAddress =  await flightSuretyApp.getOwner() 
      assert(ownerAddress, deployer)

      const airlineDetails = await flightSuretyData.getAirlineDetails(deployer)
      const { id, name, airlineAccount, state } = airlineDetails
      console.log({id, name, airlineAccount, state})

      assert(id, id.airline1)
      assert(name, airlineName.airline1)
      assert(airlineAccount, deployer)
      assert(state, 'Registered')
    })

    it('Allows registered airline to register other applied airlines', async () => {
      await flightSuretyApp.startAirlineApplication(airlineName.airline2, {from: addr1})
      await flightSuretyApp.startAirlineApplication(airlineName.airline3, {from: addr2})
      await flightSuretyApp.startAirlineApplication(airlineName.airline4, {from: addr3})
      await flightSuretyApp.startAirlineApplication(airlineName.airline5, {from: addr4})
      
      const airline1Details = await flightSuretyData.getAirlineDetails(addr1)
      const { id, name, airlineAccount, state } = airline1Details
      console.log({id, name, airlineAccount, state})
      
      assert(id, id.airline2)
      assert(name, airlineName.airline2)
      assert(airlineAccount, addr2)
      assert(state, state.Applied)
          
      await flightSuretyApp.registerAirline(addr1, 2, {from: addr1})
      const airline2Details = await flightSuretyData.getAirlineDetails(addr1)
      const { id: id2, name: name2, airlineAccount: airline2Account,state: state2 } = airline2Details

      assert(airline2Account, addr2)
      assert(state2, state.Registered)
     
    
      console.log({id2, name2, airline2Account, state2})
      
    
      await flightSuretyApp.registerAirline(addr2, 2, {from: addr1})
      const airline3Details = await flightSuretyData.getAirlineDetails(addr2)
      const { id: id3, name: name3, airlineAccount: airline3Account, state: state3 } = airline3Details
      
      console.log({id3, name3, airline3Account, state3})
      assert(airline3Account, addr2)
      assert(state3, state.Registered)
    })
  })

})