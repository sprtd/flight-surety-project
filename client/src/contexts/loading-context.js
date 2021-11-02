import { createContext, useState } from 'react';

export const LoadingContext = createContext()



const LoadingContextProvider = ({ children }) => {

  const [ isLoading, setIsLoading ] = useState(true);
  console.log('loading status', isLoading)

  const setLoading = payload => {
    setIsLoading(payload)
    
  }


  return (
    <LoadingContext.Provider value={{ setLoading, isLoading }}>
      { children }
    </LoadingContext.Provider>
  )
}

export default LoadingContextProvider