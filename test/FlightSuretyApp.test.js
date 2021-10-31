
const FlightSuretyData = artifacts.require('FlightSuretyData')
const FlightSuretyApp = artifacts.require('FlightSuretyApp')

const { toWei, fromWei } = require('../utils/conversion')

let flightSuretyApp, flightSuretyData, flightSuretyDataAddress,  deployer, addr1, addr2, addr3, addr4, addr5, addr6, addr7, addr8, addr9,  airlineName, id, state, airlines


const STATUS_CODE_UNKNOWN = 0;
const STATUS_CODE_ON_TIME = 10;
const STATUS_CODE_LATE_AIRLINE = 20;
const STATUS_CODE_LATE_WEATHER = 30;
const STATUS_CODE_LATE_TECHNICAL = 40;
const STATUS_CODE_LATE_OTHER = 50;


contract('FlightSuretyApp', async payloadAccounts => {
  deployer = payloadAccounts[0]
  addr1 = payloadAccounts[1]
  addr2 = payloadAccounts[2]
  addr3 = payloadAccounts[3]
  addr4 = payloadAccounts[4]
  addr5 = payloadAccounts[5]
  addr6 = payloadAccounts[6]
  addr7 = payloadAccounts[7]
  addr8 = payloadAccounts[8]
  addr9 = payloadAccounts[9]



  airlines = {
    addr1: payloadAccounts[1],
    addr2: payloadAccounts[2],
    addr3: payloadAccounts[3],
    addr4: payloadAccounts[4],
    addr5: payloadAccounts[5],
    addr6: payloadAccounts[6],
    addr7: payloadAccounts[7],
    addr8: payloadAccounts[8],
    addr9: payloadAccounts[9],
  }


  beforeEach(async() => {
    flightSuretyData = await FlightSuretyData.new()
    flightSuretyDataAddress = flightSuretyData.address
    flightSuretyApp = await FlightSuretyApp.new(flightSuretyDataAddress)
    
    airlineName = {
      airline1: 'alpha1',
      airline2: 'alpha2',
      airline3: 'alpha3',
      airline4: 'alpha4',
      airline5: 'alpha5',
      airline6: 'alpha6',
      airline7: 'alpha7',
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
    
    await flightSuretyApp.startAirlineApplication(airlineName.airline2, {from: addr1}) 
    await flightSuretyApp.startAirlineApplication(airlineName.airline3, {from: addr2})
    await flightSuretyApp.startAirlineApplication(airlineName.airline4, {from: addr3})
    await flightSuretyApp.startAirlineApplication(airlineName.airline5, {from: addr4})
    await flightSuretyApp.startAirlineApplication(airlineName.airline6, {from: addr5})
    await flightSuretyApp.startAirlineApplication(airlineName.airline7, {from: addr6})
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
    
  })


  contract('Airline Application', async() => {
    it('Tests Individual Airline Applications', async () => {
      const airline1Details = await flightSuretyData.getAirlineDetails(addr1)
      const { id, name, airlineAccount, state: state1 } = airline1Details
      console.log({id, 'name2': name, airlineAccount, state})
      
      assert.equal(id.toNumber(), 2)
      assert.equal(name, airlineName.airline2)
      assert.equal(airlineAccount, addr1)

      assert.equal(state1, state.Applied)

    })
  }) 



  contract('Airline Registration', () => {
    it('Allows registered airline to register other applied airlines', async () => {
      await flightSuretyApp.registerAirline(addr1, 2, {from: addr1})
      const airline2Details = await flightSuretyData.getAirlineDetails(addr1)
      const { id: id2, name: name2, airlineAccount: airline2Account,state: state2 } = airline2Details
      console.log({'id2':id2, 'name2': name2, 'airline2':airline2Account, state2})

      assert.equal(airline2Account, addr1)
      assert.equal(state2, state.Registered)      
    })

    it('Reverts 5th airline registration', async () => {
      await flightSuretyApp.registerAirline(addr1, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr2, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr3, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr4, 2, {from: addr1})
      const airline3Details = await flightSuretyData.getAirlineDetails(addr3)
      const { id: id3, name: name3, airlineAccount: airline3Account, state: state3 } = airline3Details
      
      console.log({id3, name3, airline3Account, state3})
      assert.equal(airline3Account, addr3)
      assert.equal(state3, state.Registered)
      
      const REVERT  = 'Returned error: VM Exception while processing transaction: revert contract not operational'
      
      
      try {
        await flightSuretyApp.registerAirline(addr5, 2, {from: addr1})
        throw null
      } catch(err) {
        assert(err.message.startsWith(REVERT), `Expected ${REVERT} but got ${err.message} instead`) 
      } 
    })

  }) 


  contract('Multi-party Consensus', () => {
    it('Tests multi-party consensus for 5th as well as subsequent airline registrations by already-registered airlines', async () => {
      await flightSuretyApp.registerAirline(addr1, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr2, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr3, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr4, 2, {from: addr1})
      
      await flightSuretyApp.registerViaConsensus(addr5, 2, {from: addr1})
      await flightSuretyApp.registerViaConsensus(addr5, 2, {from: addr2})

      
      const airline5Details = await flightSuretyData.getAirlineDetails(addr5)
      const { id: id5, name: name5, airlineAccount: airline5Account, state: state5 } = airline5Details
      
      assert.equal(airline5Account, addr5)
      assert.equal(state5, state.Registered)  

      await flightSuretyApp.registerViaConsensus(addr6, 2, {from: addr2})
      await flightSuretyApp.registerViaConsensus(addr6, 2, {from: addr3})
      await flightSuretyApp.registerViaConsensus(addr6, 2, {from: addr4})
      const airline6Details = await flightSuretyData.getAirlineDetails(addr6)
      const { id: id6, name: name6, airlineAccount: airline6Account, state: state6 } = airline6Details
      console.log('consensus log 6',{id6, name6, airline6Account, state6})

      assert.equal(airline6Account, addr6)
      assert.equal(state6, state.Registered)        
    })

  }) 


  contract('Airline Fee Payment', () => {
    it('Tests 10 ETH airline commitment fee payment by registered airlines', async () => {
      await flightSuretyApp.registerAirline(addr1, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr2, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr3, 2, {from: addr1})
      await flightSuretyApp.registerAirline(addr4, 2, {from: addr1})

      const dataBalanceBefore = await web3.eth.getBalance(flightSuretyDataAddress)
      console.log('dataContract balance', dataBalanceBefore)

      const AIRLINE_FEE = await flightSuretyApp.AIRLINE_FEE.call()
      
      await flightSuretyApp.payCommitmentFee({value: AIRLINE_FEE, from: addr2})
      
      const dataBalanceAfter = await web3.eth.getBalance(flightSuretyDataAddress)
      console.log('dataContract balance after', dataBalanceAfter)
      
      const ethDiff = dataBalanceAfter - dataBalanceBefore
      console.log('eth diff', fromWei(ethDiff.toString()))
      assert.equal(fromWei(AIRLINE_FEE), fromWei(ethDiff.toString())) // difference between data contract's initial ETH balance and data contract's final ETH balance equals amount paid by airline 1

      const airlineDetails = await flightSuretyData.getAirlineDetails(addr2)
      const { airlineAccount, state: newState } = airlineDetails

      assert.equal(airlineAccount, addr2)
      assert.equal(newState, state.Committed)  // airline status changes to committed after 10ETH payment

    })

  }) 
  
  contract('Flights', () => {
    it('Flight registration', async () => {

      const AIRLINE_FEE = await flightSuretyApp.AIRLINE_FEE.call()

      await flightSuretyApp.payCommitmentFee({value: AIRLINE_FEE, from: deployer})

      
      await flightSuretyData.registerFlight(STATUS_CODE_ON_TIME, {from: deployer})

      const flight1Details = await flightSuretyData.getFlightDetails(1)

      let { id, airline, flightName, statusCode, flightKey, timestamp } = flight1Details

      assert.equal(id, 1)
      assert.equal(airline, deployer)
      assert.equal(flightName, 'alpha')
      assert.equal(statusCode, STATUS_CODE_ON_TIME)
      const newTimestamp = Math.floor(Date.now() / 1000)


      
      
      console.log('flight 1 details', flight1Details)
      console.log('toString timestamp', timestamp.toString())
      
      assert.equal(timestamp.toString(), newTimestamp)
    })

  }) 

  contract('Passenger Insurance', () => {
    it('Tests passenger ability to pay 1 ETH insurance fee', async () => {
      const INSURANCE_FEE = await flightSuretyData.PASSENGER_INSURANCE_FEE.call()
      const AIRLINE_FEE = await flightSuretyApp.AIRLINE_FEE.call()

      console.log('insurance fee', fromWei(INSURANCE_FEE))
      await flightSuretyApp.payCommitmentFee({value: AIRLINE_FEE, from: deployer})

      await flightSuretyData.registerFlight(STATUS_CODE_ON_TIME, {from: deployer})


      await flightSuretyData.payInsurance(1, {from: addr9, value: INSURANCE_FEE })

      const dataBalanceAfter = await web3.eth.getBalance(flightSuretyDataAddress)

      console.log('data balance', dataBalanceAfter)

      const passengerBalance = await flightSuretyData.getPassengerBalance(addr9)

      const passengerDetails = await flightSuretyData.getPassengerDetails(addr9)

      let { id, flightAddress, flightName, passenger, state, amount, refundAmount  } = passengerDetails



      amount = fromWei(amount)


      console.log({id})
      console.log({flightAddress})
      console.log({flightName})
      console.log({passenger})
      console.log({amount})
      console.log({refundAmount})
      console.log({state})


      assert.equal(flightAddress, deployer)
      assert.equal(passenger, addr9)
      assert.equal(state, 'Paid')
      assert.equal(amount, 1)
      assert.equal(fromWei(passengerBalance), 1)
     

      console.log('passenger balance, ', fromWei(passengerBalance))
    })

  }) 

  contract('Oracle', () => {
    it('Tests oracle registration', async () => {
      const dataBalanceBefore = await web3.eth.getBalance(flightSuretyDataAddress)
      const ORACLE_REGISTRATION_FEE = await flightSuretyApp.ORACLE_REGISTRATION_FEE.call()
      const isRegisteredBefore = await flightSuretyData.isOracleRegistered(payloadAccounts[20])
      console.log('oracle state', isRegisteredBefore)
      assert.isFalse(isRegisteredBefore)

      
      await flightSuretyApp.payOracleRegFees({value: ORACLE_REGISTRATION_FEE, from: payloadAccounts[20]})
      const dataBalanceAfter = await web3.eth.getBalance(flightSuretyDataAddress)
      
      const isRegistered = await flightSuretyData.isOracleRegistered(payloadAccounts[20])
      
      console.log('oracle state', isRegistered)
      
      assert.isTrue(isRegistered)


      // Revert non-registered oracle attempt to get oracle indexes
      const REVERT  = 'Returned error: VM Exception while processing transaction: revert caller not registered oracle'
      
      try {
        await flightSuretyData.getOracleIndexes({from: payloadAccounts[19]})
        throw null
      } catch(err) {
        assert(err.message.startsWith(REVERT), `Expected ${REVERT} but got ${err.message} instead`) 
      } 
      

      //  Allow only-registered-oracle attempt to get oracle indexes
      const oracleIndexes = await flightSuretyData.getOracleIndexes({from: payloadAccounts[20]})

      console.log('oracle indexes', oracleIndexes)


      //  Allow only-registered-oracle attempt to get oracle indexes

      console.log('dataContract balance before', dataBalanceBefore)
      console.log('dataContract balance after', dataBalanceAfter)

      const ethDiff = dataBalanceAfter - dataBalanceBefore
      console.log('eth diff', fromWei(ethDiff.toString()))
      assert.equal(fromWei(ORACLE_REGISTRATION_FEE), fromWei(ethDiff.toString())) // difference between data contract's initial ETH balance and data contract's final ETH balance equals amount paid by oracle


    })
  }) 
})