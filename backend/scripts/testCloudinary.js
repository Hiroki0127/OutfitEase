const cloudinary = require('../config/cloudinary');

async function testCloudinary() {
  try {
    console.log('🔍 Testing Cloudinary configuration...');
    
    // Check if environment variables are set
    console.log('Cloud Name:', process.env.CLOUDINARY_CLOUD_NAME ? '✅ Set' : '❌ Missing');
    console.log('API Key:', process.env.CLOUDINARY_API_KEY ? '✅ Set' : '❌ Missing');
    console.log('API Secret:', process.env.CLOUDINARY_API_SECRET ? '✅ Set' : '❌ Missing');
    
    if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
      console.log('\n❌ Cloudinary environment variables are missing!');
      console.log('Please set up your .env file with:');
      console.log('CLOUDINARY_CLOUD_NAME=your_cloud_name');
      console.log('CLOUDINARY_API_KEY=your_api_key');
      console.log('CLOUDINARY_API_SECRET=your_api_secret');
      return;
    }
    
    // Test a simple upload
    console.log('\n📤 Testing image upload...');
    
    // Create a simple test image (1x1 pixel base64)
    const testImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    
    const result = await cloudinary.uploader.upload(`data:image/png;base64,${testImage}`, {
      folder: 'outfitease-test',
      public_id: 'test-upload'
    });
    
    console.log('✅ Upload successful!');
    console.log('URL:', result.secure_url);
    console.log('Public ID:', result.public_id);
    
    // Clean up - delete the test image
    await cloudinary.uploader.destroy(result.public_id);
    console.log('🧹 Test image cleaned up');
    
  } catch (error) {
    console.error('❌ Cloudinary test failed:', error.message);
  }
}

testCloudinary(); 