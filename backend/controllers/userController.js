// backend/controllers/userController.js
const User = require('../models/User'); // Import the User model

// @desc    Get user profile (including caregiver number)
// @route   GET /api/users/:userId
// @access  Private (should be protected by authMiddleware)
const getUserProfile = async (req, res) => {
  try {
    const user = await User.findOne({ userId: req.params.userId }); // Find by your unique user ID

    if (user) {
      res.json({
        userId: user.userId,
        email: user.email,
        name: user.name,
        caregiverPhoneNumber: user.caregiverPhoneNumber,
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(`Error fetching user ${req.params.userId}:`.red.bold, error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Update user's caregiver phone number
// @route   PUT /api/users/:userId/caregiver-number
// @access  Private (should be protected by authMiddleware)
const updateCaregiverPhoneNumber = async (req, res) => {
  try {
    const { userId } = req.params;
    const { phoneNumber } = req.body;

    const user = await User.findOne({ userId: userId });

    if (user) {
      user.caregiverPhoneNumber = phoneNumber; // Update the field
      await user.save(); // Save the updated user document

      res.json({
        message: 'Caregiver phone number updated successfully',
        caregiverPhoneNumber: user.caregiverPhoneNumber,
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(`Error updating caregiver phone number for user ${req.params.userId}:`.red.bold, error);
    res.status(500).json({ message: 'Server error' });
  }
};

// --- NEW: General PUT method for user profile update ---
// @desc    Update user profile details (general update)
// @route   PUT /api/users/:userId
// @access  Private (should be protected by authMiddleware)
const updateUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    // Extract fields that can be updated from the request body.
    // Use `??` (nullish coalescing operator) to keep the existing value
    // if a new value is not provided in the request body.
    const { email, name, caregiverPhoneNumber } = req.body;

    const user = await User.findOne({ userId: userId });

    if (user) {
      // Update fields only if they are provided in the request body
      user.email = email ?? user.email;
      user.name = name ?? user.name;
      user.caregiverPhoneNumber = caregiverPhoneNumber ?? user.caregiverPhoneNumber;

      // You can add more fields here if your User model expands
      // Example: user.dateOfBirth = req.body.dateOfBirth ?? user.dateOfBirth;

      await user.save(); // Save the updated user document

      res.status(200).json({
        message: 'User profile updated successfully',
        userId: user.userId,
        email: user.email,
        name: user.name,
        caregiverPhoneNumber: user.caregiverPhoneNumber,
        // Include other updated fields in the response as needed
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(`Error updating user profile for user ${req.params.userId}:`.red.bold, error);
    res.status(500).json({ message: 'Server error' });
  }
};
// --- END NEW ---

module.exports = {
  getUserProfile,
  updateCaregiverPhoneNumber,
  updateUserProfile, // Export the new function
};