
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
    it('Allows deployer register employee', async () => {
      const alpha2 = 'alpha2'
      const alpha1 = 'alpha1'
      const registerEmployee1 = await flightSuretyData.registerEmployee(alpha1, true, addr1, {from: deployer})
      const registerEmployee2 = await flightSuretyData.registerEmployee(alpha2, true, addr2, {from: deployer})
      const employeeRegistrationStatus =  await flightSuretyData.isEmployeeRegistered(alpha1)
      const employeeRegistrationStatus2 =  await flightSuretyData.isEmployeeRegistered(alpha2)
      console.log('status here', employeeRegistrationStatus)
      console.log('status here 2', employeeRegistrationStatus2)

      assert.isTrue(employeeRegistrationStatus)
      assert.isTrue(employeeRegistrationStatus2)

      truffleAssert.eventEmitted(registerEmployee1, 'LogRegistered', ev => {
        return ev.account === addr1
      })
      truffleAssert.eventEmitted(registerEmployee2, 'LogRegistered', ev => {
        return ev.account === addr2
      })
     
    })

  })

})