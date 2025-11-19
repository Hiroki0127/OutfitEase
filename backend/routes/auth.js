const express = require('express');
const router = express.Router();
const { registerUser, loginUser, updateProfile, googleSignIn } = require('../controllers/authController');
const verifyToken = require('../middleware/authMiddleware');

// Public routes - no token required
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/google', googleSignIn);

// Protected routes - token required
router.get('/test', verifyToken, (req, res) => {
  res.send('Auth route is working!');
});

router.put('/profile', verifyToken, updateProfile);

module.exports = router;
