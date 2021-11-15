import { useState, useContext } from 'react'
import { AccountContext } from '../../contexts/account-context'
import { FunctionContext } from '../../contexts/function-context'
import { TabsContext } from '../../contexts/tabs-context'
import Tabs from '../tabs/tabs.component'

import Tippy from '@tippyjs/react'
import 'tippy.js/dist/tippy.css'


import { ContentWrapper, DappContentWrapper, InputWrapper, OverviewWrapper, ProductWrapper, ToolTip } from './content.style'
import { toWei, fromWei } from '../../utils/conversion'

const Content = () => {
  let preAirline, postAirline, preFlightKey, postFlightKey
  const { productOverview,  flightSelected, productDetails } = useContext(TabsContext)
  const [contractOperationalStatus, setContractOperationalStatus] = useState(false)
  const [formFlightId, setFormFlightId] = useState('')
  const [formPassengerAddress, setFormPassengerAddress] = useState('')
  const [flightResult, setFlightResult] = useState('')
  const [passengerResult, setPassengerResult] = useState('')

  // Add airline state
  const [formAirlineName, setFormAirlineName] = useState('')
  const [formAirlineAddress, setFormAirlineAddress] = useState('')



  // Register airline state
  const [formFlightStatusCode, setFormFlightStatusCode] = useState('')
 
  // Pay insurance
  const [formInsuranceCode, setFormInsuranceCode] = useState('')

 

  let { id: flightId, airline, flightName, statusCode, flightKey, timestamp } = flightResult
  
  if(airline) {
    preAirline = airline.substring(0, 6)
    postAirline = airline.substring(37, 42)
    
    
    preFlightKey = flightKey.substring(0, 6)
    postFlightKey = flightKey.substring(37, 42)
  }

    // Pay insurance
    const [formFetchFlightID, setFormFetchFlightID] = useState('')
    
    
  let { passenger, state, amount, refundAmount  } = passengerResult


  const { flightSuretyDataContract, flightSuretyAppContract } = useContext(FunctionContext)
  const { web3Account } = useContext(AccountContext)


  /* Get Operational Status ************************ */
  const getOperationalStatus = async () => {
    try {
      const operationalStatus = await flightSuretyAppContract.methods.getOperationalStatus().call()
      console.log('operational status', operationalStatus)
      setContractOperationalStatus(operationalStatus)
      return operationalStatus
     
    } catch(err) {
      console.log(err)
    }
  }


  /* Fetch Flight Details ************************ */
  const getFlightDetails = async () => {
    try {
      const fetchedFlightDetails = await flightSuretyDataContract.methods.getFlightDetails(formFlightId).call()
      console.log('fetched details', fetchedFlightDetails)
      const status = await getOperationalStatus()
      if(fetchedFlightDetails) {
        console.log('st here', status)
        setFlightResult(fetchedFlightDetails)
        setContractOperationalStatus(status)
        
      }
    } catch(err) {
      console.log(err)
    }
  }

  /* Fetch Passenger Details ************************ */
  const getPassengerDetails = async () => {
    try {
      const fetchedPassengerDetails = await flightSuretyDataContract.methods.getPassengerDetails(formPassengerAddress).call()
      console.log('fetched details', fetchedPassengerDetails)
      setPassengerResult(fetchedPassengerDetails)

    } catch(err) {
      console.log(err)
    }
  }

  /* Apply for Airline ************************ */
  const applyForAirline = async () => {
    try {
      await flightSuretyAppContract.methods.startAirlineApplication(formAirlineName).send({ from: web3Account }) 
    } catch(err) {
      console.log(err)
    }
  }

    /* Register Airline ************************ */
  const registerAirline = async () => {
    try {
      await flightSuretyAppContract.methods.registerAirline(formAirlineAddress, 2).send({ from: web3Account }) 
    } catch(err) {
      console.log(err)
    }
  }

  /* Pay Airline Commitment Fee ************************ */
  const payAirlineCommitmentFee = async () => {
    try {
      await flightSuretyAppContract.methods.payCommitmentFee().send({ value: toWei(10), from: web3Account }) 
    } catch(err) {
      console.log(err)
    }
  }

  /* Register Flight ************************ */
  const registerFlight = async () => {
    try {
      await flightSuretyDataContract.methods.registerFlight(formFlightStatusCode).send({ from: web3Account }) 
    } catch(err) {
      console.log(err)
    }
  }

  /* Pay Insurance ************************ */
  const payInsurance = async () => {
    try {
      await flightSuretyDataContract.methods.payInsurance(formInsuranceCode).send({ from: web3Account, value: toWei(1)}) 
    } catch(err) {
      console.log(err)
    }
  }


  /* Fetch Flight Status ************************ */
  const fetchFlightStatus = async () => {
    try {
      await flightSuretyAppContract.methods.fetchFlightStatus(formFetchFlightID).send({ from: web3Account }) 
    } catch(err) {
      console.log(err)
    }
  }



  return (
    <ContentWrapper>
      <Tabs />
      <DappContentWrapper>
        {/* Overview ************************ ************************ ************************  */}
        
        {/* Find Flight */}
        <InputWrapper style={{display: productOverview ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Enter flight ID </ToolTip>}>
            <input type="number" placeholder='Enter Index' onChange={e => setFormFlightId(e.target.value) } value={ formFlightId } />
          </Tippy>
          <button onClick={ getFlightDetails } style={{marginBottom: '10vh'}}>Find Flight</button>

          <Tippy content={<ToolTip>Enter passenger address </ToolTip>}>
            <input type="text" placeholder='Enter Passenger Address' onChange={e => setFormPassengerAddress(e.target.value) } value={ formPassengerAddress } />
          </Tippy>
          <button onClick={ getPassengerDetails }>Get Passenger Details</button>


        </InputWrapper>

        <InputWrapper style={{display: productOverview ? 'flex' : 'none'}}>
         
        </InputWrapper>


        <OverviewWrapper style={{display: productOverview ? 'flex' : 'none'}}>
          <h3>Flight Overview</h3>
          { contractOperationalStatus && <p>Contract Operational Status: {` ${contractOperationalStatus}` }</p>}
          { flightId ? <p>Flight ID: { flightId }</p> : null}
          { flightName ? <p>Flight Name: { flightName.toUpperCase() }</p> : null}
          { airline ? <p>Flight Address:  { `${preAirline}...${postAirline}` }</p> : null}
          { flightKey ? <p>Flight Key: { `${preFlightKey}...${postFlightKey}` }</p> : null}
          { timestamp ? <p>Time: { timestamp }</p> : null}
          { statusCode ? <p>Status Code: { statusCode }</p> : null}
        </OverviewWrapper >

        <OverviewWrapper style={{display: productOverview ? 'flex' : 'none'}}>
          <h3>Passenger Overview</h3>
          { flightName ? <p>Flight Name: { flightName.toUpperCase() }</p> : null }
          { amount ? <p>Passenger Insurance Balance: { fromWei(amount) }ETH</p> : null}
          { passenger ? <p>Passenger Address { passenger.substring(0, 20) }</p> : null }
          { state ? <p>Passenger Status: { state }</p> : null }
          { refundAmount ? <p>RefundAmount: { fromWei(refundAmount) }</p> : null}
          
        </OverviewWrapper >
        {/* Flight ************************ ************************ ************************  */}

        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only for intending airlines</ToolTip>}>
             
          </Tippy>
            <input type="text" placeholder='Enter Airline Name' onChange={e => setFormAirlineName(e.target.value)} value={ formAirlineName}/>     
          <button onClick={ applyForAirline }>Apply For Airline</button>
        </InputWrapper>
      
        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only applied/registered airlines can register</ToolTip>}>
            <input type="text" placeholder='Airline Address' onChange={e => setFormAirlineAddress(e.target.value) }  value={ formAirlineAddress } />
          </Tippy>
          <button onClick={ registerAirline }>Register Airline</button>
        </InputWrapper>


      
        {/* Pay Airline */}
        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only registered airlines can pay flight commitment fee</ToolTip>}>
            <button onClick={ payAirlineCommitmentFee }>Pay Commitment</button>
          </Tippy>
        </InputWrapper>
      

        {/* Register Flight */}
        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={ <ToolTip>Only committed airlines can register flight</ToolTip>}>
            <input type="number" placeholder='Enter status coded' onChange={e => setFormFlightStatusCode(e.target.value) }  value={ formFlightStatusCode } />
          </Tippy>
          <button onClick={ registerFlight }>Register Flight</button>
        </InputWrapper>

        
        {/* Passenger ************************ ************************ ************************  */}
        <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Enter valid flight ID</ToolTip>}>
            <input type="number" placeholder='Enter Flight ID' onChange={e => setFormInsuranceCode(e.target.value)}  value={ formInsuranceCode } />
          </Tippy>
          <button onClick={ payInsurance }>Pay Insurance</button>
        </ProductWrapper>
              
        <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Enter valid flight id</ToolTip>}>
            <input type="number" placeholder='Enter Flight ID' onChange={e => setFormFetchFlightID(e.target.value)} value={ formFetchFlightID } />
          </Tippy>

          <button onClick={ fetchFlightStatus }>Fetch Flight Status</button>
        </ProductWrapper> 
      </DappContentWrapper>
    </ContentWrapper>
  )
}

export default Content
