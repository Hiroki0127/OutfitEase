const cloudinary = require('../config/cloudinary');
const fs = require('fs');
const crypto = require('crypto');
require('dotenv').config();

// ⬆️ GOOD: You imported all required modules correctly

exports.uploadImage = async (req, res) => {
  try {
    const { image } = req.body;

    console.log('📤 Received image upload request');
    console.log('📦 Image data length:', image ? image.length : 0);

    if (!image) return res.status(400).json({ error: 'No image data provided' });

    console.log('☁️ Uploading to Cloudinary...');
    
    // Upload base64 image to Cloudinary
    const result = await cloudinary.uploader.upload(`data:image/jpeg;base64,${image}`, {
      folder: 'outfitease',
    });

    console.log('✅ Upload successful!');
    console.log('📸 Image URL:', result.secure_url);

    // Response with Cloudinary URL
    res.json({ image_url: result.secure_url });
  } catch (err) {
    console.error('❌ Upload error:', err);
    res.status(500).json({ error: 'Image upload failed' });
  }
};

// ✅ Signature endpoint for frontend or Postman uploads
exports.getCloudinarySignature = (req, res) => {
  const timestamp = Math.floor(Date.now() / 1000);
  const folder = 'outfitease';

  const paramsToSign = `folder=${folder}&timestamp=${timestamp}`;
  const signature = crypto
    .createHash('sha1')
    .update(paramsToSign + process.env.CLOUDINARY_API_SECRET)
    .digest('hex');
    console.log('String to sign:', paramsToSign);
    console.log('Generated signature:', signature);
  res.json({
    timestamp,
    folder,
    signature,
    api_key: process.env.CLOUDINARY_API_KEY,
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  });
};
