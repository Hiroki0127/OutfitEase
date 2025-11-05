const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// This script creates a test user in Supabase
// Run this AFTER you've run schema.sql in Supabase SQL Editor

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function createTestUser() {
  try {
    console.log('👤 Setting up test user in Supabase...');
    console.log('==================================================\n');
    
    // Check connection first
    console.log('1️⃣ Testing database connection...');
    await pool.query('SELECT NOW()');
    console.log('✅ Connected to database!\n');
    
    // Test user credentials
    const email = 'hiro@example.com';
    const username = 'hiro';
    const password = 'password123';
    
    // Check if user already exists
    console.log('2️⃣ Checking if user exists...');
    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (userCheck.rows.length > 0) {
      console.log('⚠️  User already exists!');
      console.log(`   User ID: ${userCheck.rows[0].id}`);
      console.log(`   Email: ${userCheck.rows[0].email}`);
      console.log(`   Username: ${userCheck.rows[0].username}`);
      
      // Ask if they want to update password
      console.log('\n📝 Updating password to: password123');
      const hashedPassword = await bcrypt.hash(password, 10);
      await pool.query(
        'UPDATE users SET password_hash = $1 WHERE email = $2',
        [hashedPassword, email]
      );
      console.log('✅ Password updated!\n');
    } else {
      console.log('📝 User not found, creating new user...\n');
      
      // Create user
      const hashedPassword = await bcrypt.hash(password, 10);
      const result = await pool.query(
        'INSERT INTO users (email, username, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, email, username, created_at',
        [email, username, hashedPassword, 'user']
      );
      
      const user = result.rows[0];
      console.log('✅ User created successfully!');
      console.log(`   User ID: ${user.id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Username: ${user.username}`);
      console.log(`   Created: ${user.created_at}\n`);
    }
    
    console.log('✅ Test user ready!');
    console.log('==================================================');
    console.log('📧 Login Credentials:');
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log('\n🚀 You can now test login from your iOS app!');
    
    await pool.end();
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('Error code:', error.code);
    
    if (error.code === '42P01') {
      console.error('\n⚠️  Tables not found!');
      console.error('   You need to run schema.sql in Supabase first:');
      console.error('   1. Go to https://supabase.com/dashboard');
      console.error('   2. Select your project');
      console.error('   3. Click "SQL Editor"');
      console.error('   4. Paste contents of backend/schema.sql');
      console.error('   5. Click "Run"');
    } else if (error.code === '28P01' || error.code === 'ECONNREFUSED') {
      console.error('\n⚠️  Cannot connect to database!');
      console.error('   Check your DATABASE_URL in .env file');
      console.error('   Should be: postgresql://postgres:PASSWORD@db.hpzcerpgdnwrmpuiwlak.supabase.co:5432/postgres');
    }
    
    process.exit(1);
  }
}

createTestUser();

