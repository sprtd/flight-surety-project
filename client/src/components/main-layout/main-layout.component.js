import React, { useContext, useEffect } from 'react'
import { AccountContext } from '../../contexts/account-context'
import { FunctionContext } from '../../contexts/function-context'
import { getWeb3 } from '../../utils/getWeb3'
import Content from '../content/content.component'
import { MainLayoutWrapper } from './main-layout.style'
import FlightSuretyData from '../../abi/FlightSuretyData.json'
import FlightSuretyApp from '../../abi/FlightSuretyApp.json'

// flightSuretyDataContract, setDataContractInstance, flightSuretyAppContract, setAppContractInstance }
const MainLayout = () => {
  const { setAccountDetails } = useContext(AccountContext)
  const { setAppContractInstance, setDataContractInstance } = useContext(FunctionContext)

 
  const enableWeb3 = async () => {
    try {
      const web3 = await getWeb3()

      const accounts = await web3.eth.getAccounts()
      setAccountDetails(accounts[0])

     
      /* Network & Contract Config ************************ */
      const networkId = await web3.eth.net.getId()
      const  deployedNetworkData = await FlightSuretyData.networks[networkId]
      const  deployedNetworkApp = await FlightSuretyApp.networks[networkId]
    
      const flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, deployedNetworkData && deployedNetworkData.address)
      const flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, deployedNetworkApp && deployedNetworkApp.address)


   
      setAppContractInstance(flightSuretyApp)
      setDataContractInstance(flightSuretyData)
      console.log('network id', networkId)
    } catch(err) {
      console.log(err)
    }
  }

  useEffect(() => {
    enableWeb3()

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])


  return (
   <MainLayoutWrapper>
     <Content />
   </MainLayoutWrapper>
  )
}

export default MainLayout
