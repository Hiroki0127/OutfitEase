const express = require('express');
const router = express.Router();
const likesController = require('../controllers/likesController');
const authenticateToken = require('../middleware/authMiddleware');

// Get liked content (must come before parameterized routes)
router.get('/posts', authenticateToken, likesController.getLikedPosts);
router.get('/outfits', authenticateToken, likesController.getLikedOutfits);

// Post likes
router.post('/posts/:postId', authenticateToken, likesController.likePost);
router.delete('/posts/:postId', authenticateToken, likesController.unlikePost);
router.get('/posts/:postId/count', likesController.getLikesCount);

// Outfit likes
router.post('/outfits/:outfitId', authenticateToken, likesController.likeOutfit);
router.delete('/outfits/:outfitId', authenticateToken, likesController.unlikeOutfit);
router.get('/outfits/:outfitId/count', likesController.getOutfitLikesCount);

module.exports = router;
