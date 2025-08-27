const express = require('express');
const router = express.Router();
const outfitsController = require('../controllers/outfitsController');
const auth = require('../middleware/authMiddleware');
const authorizeRoles = require('../middleware/roleMiddleware');


router.use(auth);

router.post('/', outfitsController.createOutfit);
router.get('/', outfitsController.getAllOutfits);
router.get('/:id', outfitsController.getOutfitById);
router.put('/:id', outfitsController.updateOutfit);
router.delete('/:id', outfitsController.deleteOutfit);
router.delete('/:id', auth, authorizeRoles('admin'), outfitsController.deleteOutfit);

// ✅ Bulk delete multiple outfits
router.delete('/bulk/delete', outfitsController.bulkDeleteOutfits);

module.exports = router;
