const mongoose = require('mongoose')

const oracleSchema = new mongoose.Schema({
  oracles: {
    type: String,
    required: true, 
    // unique: true
  }, 
  indexes: {
    type: [Number]
  }, 
  statusCodes: {
    type: Number
  }
}, {
  timestamps: true
})

module.exports = mongoose.model('Oracle', oracleSchema)