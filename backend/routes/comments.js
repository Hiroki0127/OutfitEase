const express = require('express');
const router = express.Router();
const commentsController = require('../controllers/commentsController');

const authenticateToken = require('../middleware/authMiddleware');
const authorizeRoles = require('../middleware/roleMiddleware');
router.use(authenticateToken);

router.post('/', authenticateToken, commentsController.addComment);
router.get('/:postId', commentsController.getComments);
router.delete('/:id', commentsController.deleteComment);

// Reply routes
router.get('/:commentId/replies', commentsController.getReplies);
router.post('/:parentCommentId/replies', authenticateToken, commentsController.addReply);

module.exports = router;
