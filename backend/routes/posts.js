const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');
const authenticateToken = require('../middleware/authMiddleware');
const authorizeRoles = require('../middleware/roleMiddleware');
router.use(authenticateToken);

router.post('/', authenticateToken, postController.createPost);
router.get('/', postController.getAllPosts);//public so no auth 
router.get('/user', authenticateToken, postController.getPostsByUser);//get current user's posts
router.get('/:id', postController.getPostById);//public so no auth so pepole can see it
router.put('/:id', authenticateToken, postController.updatePost);

router.delete('/:id', authorizeRoles('admin', 'moderator'), postController.deletePost);

//router.delete('/:id', authorizeRoles('admin', 'moderator'), postController.deletePost);


module.exports = router;
