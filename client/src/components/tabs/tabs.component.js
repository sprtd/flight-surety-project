import { useContext } from "react"
import { TabsContext } from "../../contexts/tabs-context"
import { TabWrapper } from "./tabs.style"

const Tabs = () => {
  const { handleProductOverview, productOverview,  handleFlightSelected, flightSelected,  handleProductDetails, productDetails } = useContext(TabsContext)
 
  return(
    <TabWrapper>
      <h3 
        onClick={() => handleProductOverview(true)} 
        style={{background: productOverview ? 'red' : 'none', color: productOverview ? '#fff' : ' #fff', transition: '0.5s'}} 
      >Overview</h3>

      <h3 
        onClick={() => handleFlightSelected(true)}  
        style={{background: flightSelected ? 'red' : 'none', color: flightSelected  ? '#fff' : '#fff',  transition: '0.5s'}}
      >Flight</h3>


      <h3 
        onClick={() => handleProductDetails(true)} 
        style={{background: productDetails ? 'red' : 'none', color: productDetails  ? '#fff' : '#fff', transition: '0.5s'}}  
        >Passenger</h3>
    </TabWrapper>
  )

}

export default Tabs