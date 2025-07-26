const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  // ... other user fields
  caregiverPhoneNumber: {
    type: String, // Store phone numbers as strings
    default: null
  }
});

module.exports = mongoose.model('User', UserSchema);