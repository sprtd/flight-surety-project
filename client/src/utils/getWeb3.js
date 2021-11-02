import Web3 from "web3";

const getWeb3 = () =>
  new Promise((resolve, reject) => {
    // Wait for loading completion to avoid race conditions with web3 injection timing.
    window.addEventListener("load", async () => {

      const { ethereum } = window
      // Modern dapp browsers...
      if (ethereum) {
        const web3 = new Web3(ethereum);
        try {
          // Request account access if needed
          await ethereum.request({ method: 'eth_requestAccounts' });

          ethereum.on('accountsChanged', () => {
            window.location.reload()
          })

          ethereum.on('chainChanged', () => {
            window.location.reload()
          })

          // Accounts now exposed
          resolve(web3);
        } catch (error) {
          reject(error);
        }
      }
      // Legacy dapp browsers...
      else if (window.web3) {
        // Use Mist/MetaMask's provider.
        const web3 = window.web3;
        console.log("Injected web3 detected.");
        resolve(web3);
      }
      // Fallback to localhost; use dev console port by default...
      else {
        alert('You need to install MetaMask')
      }
    });
  });

export { getWeb3 };
