require('dotenv').config()
const mongoose = require('mongoose')
const { MONGO_URI } = process.env


const connectionOptions = {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    socketTimeoutMS: 45000,
    keepAlive: true,
  }



const connectDB = async () => {
  try {
    await mongoose.connect(MONGO_URI, connectionOptions)
    console.log('connected to mongo')
  } catch(err) {
    console.log('mongo connection err', err)
  }
}

module.exports = { connectDB }