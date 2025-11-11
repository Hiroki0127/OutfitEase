const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/authMiddleware');
const followController = require('../controllers/followController');

router.use(authenticateToken);

router.post('/:id', followController.followUser);
router.delete('/:id', followController.unfollowUser);
router.get('/status/:id', followController.getFollowStatus);
router.get('/stats/:id', followController.getFollowStats);
router.get('/followers/:id', followController.getFollowers);
router.get('/following/:id', followController.getFollowing);

module.exports = router;

