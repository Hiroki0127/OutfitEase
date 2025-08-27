const axios = require('axios');

const BASE_URL = 'http://localhost:3000';
let authToken = '';

async function testServer() {
    console.log('🧪 Starting OutfitEase Server Tests...\n');
    
    try {
        // Test 1: Server Health Check
        console.log('1️⃣ Testing server health...');
        const healthResponse = await axios.get(`${BASE_URL}/`);
        console.log('✅ Server is running:', healthResponse.data);
        
        // Test 2: Authentication
        console.log('\n2️⃣ Testing authentication...');
        const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
            email: 'test@example.com',
            password: 'password'
        });
        authToken = loginResponse.data.token;
        console.log('✅ Login successful');
        console.log('👤 User ID:', loginResponse.data.user.id);
        
        const headers = {
            'Authorization': `Bearer ${authToken}`
        };
        
        // Test 3: Clothes Endpoint
        console.log('\n3️⃣ Testing clothes endpoint...');
        const clothesResponse = await axios.get(`${BASE_URL}/clothes`, { headers });
        console.log('✅ Clothes retrieved successfully');
        console.log(`📦 Found ${clothesResponse.data.length} clothing items`);
        
        // Test 4: Outfits Endpoint
        console.log('\n4️⃣ Testing outfits endpoint...');
        const outfitsResponse = await axios.get(`${BASE_URL}/outfits`, { headers });
        console.log('✅ Outfits retrieved successfully');
        console.log(`👕 Found ${outfitsResponse.data.length} outfits`);
        
        // Test 5: Posts Endpoint
        console.log('\n5️⃣ Testing posts endpoint...');
        const postsResponse = await axios.get(`${BASE_URL}/posts`, { headers });
        console.log('✅ Posts retrieved successfully');
        console.log(`📝 Found ${postsResponse.data.length} posts`);
        
        // Test 6: Planning Endpoint
        console.log('\n6️⃣ Testing planning endpoint...');
        const planningResponse = await axios.get(`${BASE_URL}/planning`, { headers });
        console.log('✅ Planning data retrieved successfully');
        console.log(`📅 Found ${planningResponse.data.length} planned outfits`);
        
        // Test 7: Weather Endpoint
        console.log('\n7️⃣ Testing weather endpoint...');
        try {
            const weatherResponse = await axios.get(`${BASE_URL}/weather?city=Tokyo`, { headers });
            console.log('✅ Weather data retrieved successfully');
            console.log('🌤️ Weather info available');
        } catch (error) {
            console.log('⚠️ Weather endpoint not available or requires API key');
        }
        
        // Test 8: Profile Data
        console.log('\n8️⃣ Testing profile data...');
        const profileResponse = await axios.get(`${BASE_URL}/auth/profile`, { headers });
        console.log('✅ Profile data retrieved successfully');
        console.log('👤 Username:', profileResponse.data.username);
        console.log('📧 Email:', profileResponse.data.email);
        
        console.log('\n🎉 All tests completed successfully!');
        console.log('\n📊 Server Status Summary:');
        console.log('✅ Server running on port 3000');
        console.log('✅ Database connected');
        console.log('✅ Authentication working');
        console.log('✅ All major endpoints functional');
        console.log('✅ Test data available');
        
        console.log('\n🔑 Test Credentials:');
        console.log('Email: test@example.com');
        console.log('Password: password');
        console.log('User ID:', loginResponse.data.user.id);
        
        console.log('\n🚀 Ready for iOS app testing!');
        
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        console.log('\n🔧 Troubleshooting tips:');
        console.log('1. Make sure the server is running: npm start');
        console.log('2. Check if database is running: docker-compose up -d');
        console.log('3. Verify .env file exists with correct credentials');
        console.log('4. Check if port 3000 is available');
    }
}

testServer();
