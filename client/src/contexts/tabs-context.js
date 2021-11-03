import { useState, createContext } from 'react'


export const TabsContext = createContext()


const TabsContextProvider = ({ children }) => {

  const [productOverview, setProductOverview] = useState(true)
  const [flightSelected, setFlightSelected] = useState(false)
  const [productDetails, setProductDetails] = useState(false)


  const handleProductOverview = () => {
    setProductOverview(true)
    setFlightSelected(false)
    setProductDetails(false)
  }

  const handleFlightSelected = () => {
    setFlightSelected(true)
    setProductOverview(false)
    setProductDetails(false)
  }
  

  const handleProductDetails = () => {
    setProductDetails(true)
    setProductOverview(false)
    setFlightSelected(false)
  }

 
  
  return(
    <TabsContext.Provider 
      value={{ 
        handleProductOverview, 
        productOverview,
        handleFlightSelected,
        flightSelected,
        handleProductDetails,
        productDetails,
      }}
    >
      { children }
    </TabsContext.Provider>
  )

}

export default TabsContextProvider