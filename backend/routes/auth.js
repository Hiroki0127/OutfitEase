const express = require('express');
const router = express.Router();
const { registerUser, loginUser, updateProfile } = require('../controllers/authController');
const verifyToken = require('../middleware/authMiddleware');

// Public routes - no token required
router.post('/register', registerUser);
router.post('/login', loginUser);

// Protected routes - token required
router.get('/test', verifyToken, (req, res) => {
  res.send('Auth route is working!');
});

router.put('/profile', verifyToken, updateProfile);

module.exports = router;
