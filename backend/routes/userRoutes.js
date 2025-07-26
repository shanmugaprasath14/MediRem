// backend/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { getUserProfile, updateCaregiverPhoneNumber } = require('../controllers/userController'); // Import controller functions
// const protect = require('../middleware/authMiddleware'); // If you have authentication middleware

// @desc    Get user profile (including caregiver number)
// @route   GET /api/users/:userId
// @access  Private
router.get('/:userId', getUserProfile); // Just reference the controller function

// @desc    Update user's caregiver phone number
// @route   PUT /api/users/:userId/caregiver-number
// @access  Private
router.put('/:userId/caregiver-number', updateCaregiverPhoneNumber); // Just reference the controller function

module.exports = router;