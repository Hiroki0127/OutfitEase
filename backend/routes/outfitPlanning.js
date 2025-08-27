const express = require('express');
const router = express.Router();
const planningController = require('../controllers/outfitPlanningController');
const verifyToken = require('../middleware/authMiddleware');

router.use(verifyToken);

router.get('/', planningController.getAllPlanning);
router.post('/', planningController.createPlanning);
router.delete('/:id', planningController.deletePlanning);

module.exports = router;
