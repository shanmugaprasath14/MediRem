// medirem-backend/routes/medicationRoutes.js
const express = require('express');
const router = express.Router();

// Import all necessary controllers
// Make sure the paths to your controllers are correct relative to this file
const medicationController = require('../controllers/medicationController');
const caretakerController = require('../controllers/caretakerController');

// --- Medication Routes ---
// These routes will be accessed as /api/medications (because of mounting in app.js)
router.route('/medications')
    .get(medicationController.getMedications)
    .post(medicationController.addMedication);

router.route('/medications/:id')
    .get(medicationController.getMedication)
    .put(medicationController.updateMedication)
    .delete(medicationController.deleteMedication);

// --- Caretaker Routes ---
// These routes will be accessed as /api/caretaker (because of mounting in app.js)
router.get('/caretaker/:userId', caretakerController.getCaretakerByUserId);
router.post('/caretaker', caretakerController.createCaretaker); // Ensure createCaretaker logic is upsert if desired
router.put('/caretaker/:userId', caretakerController.updateCaretakerByUserId);

module.exports = router; // Export this single combined router