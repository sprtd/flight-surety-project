import { useState, createContext } from 'react'

export const FunctionContext = createContext()


const FunctionContextProvider = ({ children }) => {

  const [flightSuretyDataContract, setFlightSuretyData] = useState('')
  const [flightSuretyAppContract, setFlightSuretyContract] = useState('')

  // set flightSuretyDataContract instance
  const setDataContractInstance = payload => {
    setFlightSuretyData(payload)
  }
  // set flightSuretyAppContract instance
  const setAppContractInstance = payload => {
    setFlightSuretyContract(payload)
  }

 
  return(
    <FunctionContext.Provider value={{ flightSuretyDataContract, setDataContractInstance, flightSuretyAppContract, setAppContractInstance }}>
      { children }
    </FunctionContext.Provider>

  )
}


export default FunctionContextProvider