const axios = require('axios');

async function testRender() {
  const baseURL = 'https://outfitease.onrender.com';
  
  console.log('🧪 Testing Render Deployment');
  console.log('==================================================');
  console.log(`📍 Server URL: ${baseURL}\n`);
  
  try {
    // Test 1: Server health
    console.log('1️⃣ Testing server health...');
    const healthResponse = await axios.get(`${baseURL}/`, { timeout: 10000 });
    console.log(`✅ Server is running: ${healthResponse.data.message || 'OK'}\n`);
    
    // Test 2: Login with test credentials
    console.log('2️⃣ Testing login...');
    console.log('   Email: hiro@example.com');
    console.log('   Password: password123');
    
    try {
      const loginResponse = await axios.post(
        `${baseURL}/auth/login`,
        {
          email: 'hiro@example.com',
          password: 'password123'
        },
        { timeout: 120000 } // 120 seconds for Render wake-up
      );
      
      console.log('✅ Login successful!');
      console.log(`   Token: ${loginResponse.data.token?.substring(0, 20)}...`);
      console.log(`   User: ${loginResponse.data.user?.username || loginResponse.data.user?.email}`);
      console.log(`   User ID: ${loginResponse.data.user?.id}\n`);
      
      // Test 3: Protected endpoint
      console.log('3️⃣ Testing protected endpoint...');
      const clothesResponse = await axios.get(
        `${baseURL}/clothes`,
        {
          headers: {
            'Authorization': `Bearer ${loginResponse.data.token}`
          },
          timeout: 30000
        }
      );
      
      console.log(`✅ Protected endpoint successful`);
      console.log(`   Found ${clothesResponse.data?.length || 0} clothing items\n`);
      
      console.log('✅ All tests passed!');
      
    } catch (loginError) {
      if (loginError.response) {
        console.log(`❌ Login failed: ${loginError.response.status}`);
        console.log(`   Response:`, loginError.response.data);
        
        if (loginError.response.status === 500) {
          console.log('\n⚠️  Server error detected!');
          console.log('   This usually means:');
          console.log('   1. DATABASE_URL not set correctly in Render');
          console.log('   2. Database connection issue (IPv6/IPv4)');
          console.log('   3. Schema not run in Supabase');
          console.log('\n   Check Render logs for details.');
        } else if (loginError.response.status === 400) {
          console.log('\n⚠️  Invalid credentials');
          console.log('   User might not exist in Supabase');
          console.log('   Run schema.sql in Supabase SQL Editor');
        }
      } else {
        console.log(`❌ Network error: ${loginError.message}`);
        if (loginError.code === 'ECONNABORTED') {
          console.log('   Server might be spinning up (Render free tier)');
          console.log('   Wait 50-60 seconds and try again');
        }
      }
    }
    
  } catch (error) {
    if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
      console.log('❌ Server not responding');
      console.log('   Check if Render service is running');
      console.log('   Go to: https://dashboard.render.com');
    } else {
      console.log(`❌ Error: ${error.message}`);
    }
  }
}

testRender();

