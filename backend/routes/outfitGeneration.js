const express = require('express');
const router = express.Router();
const outfitGenerationController = require('../controllers/outfitGenerationController');
const verifyToken = require('../middleware/authMiddleware');

// Protect all routes
router.use(verifyToken);

// Generate outfits based on filters
router.post('/generate', outfitGenerationController.generateOutfits);

// Generate weather-based outfits
router.post('/weather-based', outfitGenerationController.generateWeatherBasedOutfits);

// Get event-specific suggestions
router.get('/event/:eventType', outfitGenerationController.getEventSuggestions);

module.exports = router; 