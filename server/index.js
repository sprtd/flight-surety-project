// require('dotenv').config()r
const http = require('http')

const app = require('./server')

const server = http.createServer(app)

let currentApp = app


const PORT = process.env.PORT
server.listen(PORT)

if(module.hot) {
  module.hot.accept('./server', () => {
    server.removeAllListener('request', currentApp)
    server.on('request', app)
    currentApp = app
  })
}
