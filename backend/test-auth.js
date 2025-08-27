const axios = require('axios');

async function testAuth() {
    try {
        console.log('Testing authentication...');
        
        // Step 1: Login
        console.log('1. Attempting login...');
        const loginResponse = await axios.post('http://localhost:3000/auth/login', {
            email: 'test@example.com',
            password: 'password'
        });
        
        console.log('✅ Login successful');
        console.log('Token:', loginResponse.data.token);
        
        // Step 2: Test protected endpoint
        console.log('2. Testing protected endpoint...');
        const token = loginResponse.data.token;
        
        const clothesResponse = await axios.get('http://localhost:3000/clothes', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        
        console.log('✅ Protected endpoint successful');
        console.log('Clothes data:', clothesResponse.data);
        
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
    }
}

testAuth(); 