const express = require('express');
const router = express.Router();
const clothesController = require('../controllers/clothesController');
const verifyToken = require('../middleware/authMiddleware');

// Protect all clothes routes
router.use(verifyToken);

router.post('/', clothesController.createClothingItem);
router.get('/', clothesController.getClothingItems);
router.get('/:id', clothesController.getClothingItemById);
router.put('/:id', clothesController.updateClothingItem);
router.delete('/:id', clothesController.deleteClothingItem);

// ✅ Bulk delete multiple clothing items
router.delete('/bulk/delete', clothesController.bulkDeleteClothingItems);

module.exports = router;
