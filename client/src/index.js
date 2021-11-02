import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { GlobalStyle } from './components/global-style/global-style';
import AccountContextProvider from './contexts/account-context';
import FunctionContextProvider from './contexts/function-context';
import LoadingContextProvider from './contexts/loading-context';
import TabsContextProvider from './contexts/tabs-context';

ReactDOM.render(
  <React.StrictMode>
    <GlobalStyle />
    <AccountContextProvider>
      <FunctionContextProvider>
        <LoadingContextProvider>
          <TabsContextProvider>
            <App />
          </TabsContextProvider>
        </LoadingContextProvider>
      </FunctionContextProvider>
    </AccountContextProvider>
  </React.StrictMode>,
  document.getElementById('root')
);


