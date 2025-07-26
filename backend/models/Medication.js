// models/Medication.js
const mongoose = require('mongoose');

const medicationSchema = mongoose.Schema(
    {
        medicineName: {
            type: String,
            required: true,
        },
        time: {
            type: String, // Storing time as a string (e.g., "10:00 AM")
            required: true,
        },
        status: {
            type: String,
            enum: ['Scheduled', 'Completed', 'Skipped', 'Before Eating', 'After Eating', 'Upcoming'], // Example statuses
            default: 'Scheduled',
        },
        pillCount: {
            type: Number,
            default: 1,
        },
        daysDuration: {
            type: Number,
            default: 0, // 0 for indefinite, or number of days
        },
        mealTiming: {
            type: String, // e.g., 'morning_before', 'morning_after', 'afternoon_before', 'night_after'
            default: 'any_time',
        },
        imagePath: {
            type: String, // Path or URL to the image (if stored externally like S3)
            default: '',
        },
    },
    {
        timestamps: true, // Adds createdAt and updatedAt fields automatically
    }

);

const Medication = mongoose.model('Medication', medicationSchema);

module.exports = Medication;