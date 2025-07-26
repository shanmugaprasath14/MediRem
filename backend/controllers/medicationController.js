// controllers/medicationController.js
const Medication = require('../models/Medication');
const asyncHandler = require('express-async-handler');

// @desc    Get all medication plans
// @route   GET /api/medications
// @access  Public (or Private with authentication)
const getMedications = asyncHandler(async (req, res) => {
    const medications = await Medication.find({});
    res.json(medications);
});

// --- NEW FUNCTION: Get a single medication plan by ID ---
// @desc    Get single medication plan
// @route   GET /api/medications/:id
// @access  Public
const getMedication = asyncHandler(async (req, res) => {
    // console.log('Attempting to fetch medication with ID:', req.params.id); // Add for debugging

    const medication = await Medication.findById(req.params.id);

    if (medication) {
        // console.log('Medication found:', medication); // Add for debugging
        res.status(200).json(medication);
    } else {
        // console.log('Medication not found for ID:', req.params.id); // Add for debugging
        res.status(404);
        throw new Error('Medication not found'); // This is the error message Flutter receives
    }
});
// --- END NEW FUNCTION ---


// @desc    Add a new medication plan
// @route   POST /api/medications
// @access  Public
const addMedication = asyncHandler(async (req, res) => {
    const { medicineName, time, status, pillCount, daysDuration, mealTiming, imagePath } = req.body;

    if (!medicineName || !time) {
        res.status(400);
        throw new Error('Please enter medicine name and time');
    }

    const medication = new Medication({
        medicineName,
        time,
        status: status || 'Scheduled', // Default status
        pillCount,
        daysDuration,
        mealTiming,
        imagePath,
    });

    const createdMedication = await medication.save();
    res.status(201).json(createdMedication);
});

// @desc    Update a medication plan
// @route   PUT /api/medications/:id
// @access  Public
const updateMedication = asyncHandler(async (req, res) => {
    const { medicineName, time, status, pillCount, daysDuration, mealTiming, imagePath } = req.body;

    const medication = await Medication.findById(req.params.id);

    if (medication) {
        medication.medicineName = medicineName || medication.medicineName;
        medication.time = time || medication.time;
        medication.status = status || medication.status;
        medication.pillCount = pillCount !== undefined ? pillCount : medication.pillCount;
        medication.daysDuration = daysDuration !== undefined ? daysDuration : medication.daysDuration;
        medication.mealTiming = mealTiming || medication.mealTiming;
        medication.imagePath = imagePath || medication.imagePath;

        const updatedMedication = await medication.save();
        res.json(updatedMedication);
    } else {
        res.status(404);
        throw new Error('Medication not found');
    }
});

// @desc    Delete a medication plan
// @route   DELETE /api/medications/:id
// @access  Public
const deleteMedication = asyncHandler(async (req, res) => {
    const medication = await Medication.findById(req.params.id);

    if (medication) {
        await medication.deleteOne(); // Use deleteOne for Mongoose 6+
        res.json({ message: 'Medication removed' });
    } else {
        res.status(404);
        throw new Error('Medication not found');
    }
});

module.exports = {
    getMedications,
    addMedication,
    getMedication, // <--- EXPORT THE NEW FUNCTION
    updateMedication,
    deleteMedication,
};