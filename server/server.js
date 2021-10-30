require('dotenv').config()

const express = require('express')
const app = express()

const morgan = require('morgan')
const cors = require('cors')





app.use(cors())
app.use(express.json())
app.use(morgan('dev'))



const PORT = process.env.PORT
app.listen(PORT, () => console.log(`server running on port ${PORT}`))