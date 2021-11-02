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
  const { productOverview,  flightSelected, productDetails } = useContext(TabsContext)
  const [formFlightId, setFormFlightId] = useState('')
  const [formPassengerAddress, setFormPassengerAddress] = useState('')
  const [flightResult, setFlightResult] = useState('')
  const [passengerResult, setPassengerResult] = useState('')
  const [productResult, setProductResult] = useState('')

  const { id: flightId, airline, flightName, statusCode, flightKey, timestamp } = flightResult

  const { id, flightAddress, flightName: flightFetchedName, passenger, state, amount, refundAmount  } = passengerResult




  const { flightSuretyDataContract, flightSuretyAppContract } = useContext(FunctionContext)
  const { web3Account } = useContext(AccountContext)
  const [sku, setSKU] = useState('')


 
  const initialPassengerInsurance =  {
    index: '', 
    flightID: ''
  }


  /* Handle Passenger Insurance ************************ */
  const [passengerInsurance, setPassengerInsurance] = useState(initialPassengerInsurance)
  const handlePassengerInsuranceChange = e => {
    const { name, value } = e.target
    setPassengerInsurance(prev => ({...prev, [name]: value}))
  }
  
 

  /* Handle Fetch Flight Details ************************ */
  const getFlightDetails = async () => {
    try {
      const fetchedFlightDetails = await flightSuretyDataContract.methods.getFlightDetails(formFlightId).call()
      // const fetchedPassengerDetails = await flightSuretyDataContract.methods.getPassengerDetails(formFlightId).call()
      console.log('fetched details', fetchedFlightDetails)
      setFlightResult(fetchedFlightDetails)
      // setPassengerResult(fetchedPassengerDetails)
    

    } catch(err) {
      console.log(err)
    }
  }


  /* Handle Fetch Passenger Details ************************ */
  const getPassengerDetails = async () => {
    try {
      const fetchedPassengerDetails = await flightSuretyDataContract.methods.getPassengerDetails(formPassengerAddress).call()
      console.log('fetched details', fetchedPassengerDetails)
      setPassengerResult(fetchedPassengerDetails)

    } catch(err) {
      console.log(err)
    }
  }

  /* Handle Add Retailer ************************ */
  const initialFlightState = {
    id: '',
    address: ''
  }

  const [retailer, setRetailer] = useState(initialFlightState)

  const handleRetailerChange = e => {
    const { name, value } = e.target
    setRetailer(prev => ({...prev, [name]: value}))
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
            <input type="text" placeholder='Enter Index' onChange={e => setFormPassengerAddress(e.target.value) } value={ formPassengerAddress } />
          </Tippy>
          <button onClick={ getPassengerDetails }>Get Passenger Details</button>


        </InputWrapper>

        <InputWrapper style={{display: productOverview ? 'flex' : 'none'}}>
         
        </InputWrapper>


        {/* <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Fetch fight status</ToolTip>}>
            <input type="number" placeholder='Enter Index' onChange={e => setFormFlightId(e.target.value) } name='SKU' value={ formFlightId } />
          </Tippy>

          <button onClick={ handleOver }>Fetch Flight Details</button>
        </ProductWrapper> */}


        <OverviewWrapper style={{display: productOverview ? 'flex' : 'none'}}>
          <h3>Flight Overview</h3>
          { flightId ? <p>Flight ID: { flightId }</p> : null}
          { flightName ? <p>Flight Name: { flightName }</p> : null}
          { airline ? <p>Flight Address:  { airline.substring(0, 20) }</p> : null}
          { flightKey ? <p>Flight Key: { flightKey.substring(0, 20) }</p> : null}
          { timestamp ? <p>Time: { timestamp }</p> : null}
          { statusCode ? <p>Status Code: { statusCode }</p> : null}
        </OverviewWrapper >




        <OverviewWrapper style={{display: productOverview ? 'flex' : 'none'}}>
          <h3>Passenger Overview</h3>
          { flightName ? <p>Flight Name: { flightName }</p> : null }
          { amount ? <p>Passenger Insurance Balance: { fromWei(amount) }ETH</p> : null}
          { passenger ? <p>Passenger Address { passenger.substring(0, 20) }</p> : null }
          { state ? <p>Passenger Status: { state }</p> : null }
          { refundAmount ? <p>RefundAmount: { fromWei(refundAmount) }</p> : null}
          
        </OverviewWrapper >
  
   

        {/* Flight ************************ ************************ ************************  */}

        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only for intending airlines</ToolTip>}>
             
          </Tippy>
            <input type="text" placeholder='Enter Airline Name' onChange={ '' } name='airlineName'  />            
          <button onClick={ '' }>Apply For Airline</button>
        </InputWrapper>
      
        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only applied/registered airlines can register</ToolTip>}>
          <input type="text" placeholder='Airline Address' onChange={ '' } name=''  value={ '' } />
          </Tippy>
         
          <button onClick={ '' }>Register Airline</button>
        </InputWrapper>

        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Only registered airlines can pay flight commitment fee</ToolTip>}>
          </Tippy>
          <button onClick={ '' }>Pay Commitment</button>
        </InputWrapper>
      

      
        <InputWrapper style={{display: flightSelected ? 'flex' : 'none'}}>
          <Tippy content={ <ToolTip>Only committed airlines can register flight</ToolTip>}>
            <input type="number" placeholder='Enter status coded' onChange={ '' }  name='SKU' value={ '' } />
          </Tippy>
          <button onClick={ '' }>Register Flight</button>
        </InputWrapper>

        
        {/* Passenger ************************ ************************ ************************  */}
        <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Enter valid flight ID</ToolTip>}>
            <input type="number" placeholder='Enter Flight ID' onChange={ handleRetailerChange } name='SKU' value={ retailer.SKU } />
          </Tippy>

          <button onClick={ '' }>Pay Insurance</button>
        </ProductWrapper>

        <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>check insurance</ToolTip>}>
            <input type="number" placeholder='Enter Index' onChange={ handleRetailerChange } name='SKU' value={ retailer.SKU } />
          </Tippy>

          <button onClick={ '' }>Check Insurance</button>
        </ProductWrapper>

      
        <ProductWrapper style={{display: productDetails ? 'flex' : 'none'}}>
          <Tippy content={<ToolTip>Enter valid flight id</ToolTip>}>
            <input type="number" placeholder='Enter Index' onChange={ handleRetailerChange } name='SKU' value={ retailer.SKU } />
          </Tippy>
          <input type="number" placeholder='Enter Flight ID' onChange={ handleRetailerChange } name='SKU' value={ retailer.SKU } />

          <button onClick={ '' }>Fetch Flight Status</button>
        </ProductWrapper>
        
      </DappContentWrapper>
    </ContentWrapper>
  )
}

export default Content
