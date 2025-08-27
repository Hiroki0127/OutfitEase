const express = require('express');
const router = express.Router();
const savedOutfitsController = require('../controllers/savedOutfitsController');
const authenticateToken = require('../middleware/authMiddleware');

// Get saved outfits
router.get('/', authenticateToken, savedOutfitsController.getSavedOutfits);

// Save an outfit
router.post('/:outfitId', authenticateToken, savedOutfitsController.saveOutfit);

// Unsave an outfit
router.delete('/:outfitId', authenticateToken, savedOutfitsController.unsaveOutfit);

// Check if an outfit is saved
router.get('/:outfitId/status', authenticateToken, savedOutfitsController.checkSavedStatus);

// Bulk unsave outfits
router.delete('/bulk/unsave', authenticateToken, savedOutfitsController.bulkUnsaveOutfits);

module.exports = router;
