// medirem-backend/models/Caretaker.js
const mongoose = require('mongoose');

// Define the schema for the Caretaker document
const caretakerSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true, // Ensures each user has only one caretaker number entry
    index: true   // Add an index for faster lookups by userId
  },
  phoneNumber: {
    type: String,
    required: true
  },
  lastUpdated: {
    type: Date,
    default: Date.now // Automatically set the current time on creation/update
  }
}, {
  timestamps: true // Adds createdAt and updatedAt fields automatically
});

// Create the Mongoose model from the schema
const Caretaker = mongoose.model('Caretaker', caretakerSchema);

module.exports = Caretaker; // Export the model for use in controllers