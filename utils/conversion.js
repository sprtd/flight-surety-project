// conversion helpers
const toWei = payload => web3.utils.toWei(payload.toString(), 'ether')
const fromWei = payload => web3.utils.fromWei(payload.toString(), 'ether')
const ETHBalance = payload => web3.eth.getBalance(payload)


module.exports = {
  toWei, fromWei, ETHBalance
}