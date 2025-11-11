const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/authMiddleware');
const usersController = require('../controllers/usersController');

router.use(authenticateToken);

router.get('/:id', usersController.getPublicProfile);

module.exports = router;

