const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');

router.post('/', uploadController.uploadImage);

// 💡 Add this route to generate signature for direct client uploads (optional)
router.get('/cloudinary-signature', uploadController.getCloudinarySignature);

module.exports = router;
