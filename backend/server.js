// app.js (Your Main Server File)
const express = require('express');
const dotenv = require('dotenv');
const colors = require('colors'); // Optional for colorful console logs
const connectDB = require('./config/db');

// --- CORRECTED IMPORT: Use your single combined routes file ---
const medicationRoutes = require('./routes/medicationRoutes'); // THIS IS NOW YOUR COMBINED FILE

const { notFound, errorHandler } = require('./utils/errorHandler'); // Your error handlers

dotenv.config(); // Load environment variables

connectDB(); // Connect to MongoDB

const app = express();

// Middleware to parse JSON request bodies
app.use(express.json());

// Basic route for testing
app.get('/', (req, res) => {
    res.send('API is running...');
});

// --- CORRECTED MOUNTING: Mount your combined routes under '/api' ---
// Now, all routes defined inside medicationRoutes.js will be prefixed with '/api'
// E.g., /api/medications, /api/caretaker
app.use('/api', medicationRoutes); // <--- Make sure this line is correct

// Error handling middleware (should be last, after all routes)
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000; // Use your desired default port

app.listen(PORT, console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`.yellow.bold));