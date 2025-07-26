// medirem-backend/controllers/caretakerController.js
const Caretaker = require('../models/Caretaker');

// Controller function to get a caretaker's phone number by userId
exports.getCaretakerByUserId = async (req, res) => {
  try {
    const { userId } = req.params;
    const caretaker = await Caretaker.findOne({ userId });

    if (!caretaker) {
      return res.status(404).json({ message: 'Caretaker number not found for this user.' });
    }

    res.status(200).json(caretaker);
  } catch (err) {
    console.error('Error getting caretaker:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// Controller function to create or initial save of caretaker number (POST /api/caretaker)
// This currently acts as an upsert (create if not exists, update if exists)
exports.createCaretaker = async (req, res) => {
  try {
    const { userId, phoneNumber } = req.body;

    if (!userId || !phoneNumber) {
      return res.status(400).json({ message: 'User ID and Phone Number are required.' });
    }

    const updatedCaretaker = await Caretaker.findOneAndUpdate(
      { userId }, // Query to find by userId
      { phoneNumber, lastUpdated: Date.now() }, // Data to update
      { upsert: true, new: true, setDefaultsOnInsert: true } // Create if not found, return new doc
    );

    res.status(200).json({
      message: 'Caretaker number created/updated successfully!',
      caretaker: updatedCaretaker
    });
  } catch (err) {
    console.error('Error saving caretaker:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// NEW: Controller function to update an existing caretaker's phone number (PUT /api/caretaker/:userId)
exports.updateCaretakerByUserId = async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL parameters
    const { phoneNumber } = req.body; // Get phoneNumber from request body

    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone Number is required for update.' });
    }

    // Find the document by userId and update it
    // 'new: true' returns the modified document rather than the original
    // IMPORTANT: No 'upsert: true' here, as PUT typically implies the resource exists.
    const updatedCaretaker = await Caretaker.findOneAndUpdate(
      { userId }, // Query to find by userId
      { phoneNumber, lastUpdated: Date.now() }, // Data to update
      { new: true }
    );

    if (!updatedCaretaker) {
      // If no document was found and updated, it means the userId doesn't exist.
      return res.status(404).json({ message: 'Caretaker contact not found for this user.' });
    }

    res.status(200).json({
      message: 'Caretaker number updated successfully!',
      caretaker: updatedCaretaker
    });
  } catch (err) {
    console.error('Error updating caretaker:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};