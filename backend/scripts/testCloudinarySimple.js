const cloudinary = require('../config/cloudinary');

async function testCloudinarySimple() {
  try {
    console.log('🔍 Testing Cloudinary with simple upload...');
    
    // Test a simple upload without public_id
    const testImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    
    const result = await cloudinary.uploader.upload(`data:image/png;base64,${testImage}`, {
      folder: 'outfitease-test'
    });
    
    console.log('✅ Upload successful!');
    console.log('URL:', result.secure_url);
    console.log('Public ID:', result.public_id);
    
    // Clean up
    
    await cloudinary.uploader.destroy(result.public_id);
    console.log('🧹 Test image cleaned up');
    
  } catch (error) {
    console.error('❌ Cloudinary test failed:', error.message);
    console.error('Full error:', error);
  }
}

testCloudinarySimple(); 