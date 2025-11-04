const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function listUsers() {
  try {
    const client = await pool.connect();
    
    console.log('👥 Registered Users in Database');
    console.log('='.repeat(80));
    
    // Fetch all users
    const usersResult = await client.query(
      `SELECT 
        id, 
        email, 
        username, 
        avatar_url, 
        role,
        created_at,
        (SELECT COUNT(*) FROM clothing_items WHERE user_id = users.id) as clothing_count,
        (SELECT COUNT(*) FROM outfits WHERE user_id = users.id) as outfit_count,
        (SELECT COUNT(*) FROM posts WHERE user_id = users.id) as post_count
      FROM users 
      ORDER BY created_at DESC`
    );
    
    if (usersResult.rows.length === 0) {
      console.log('❌ No users found in the database');
    } else {
      console.log(`\n📊 Total Users: ${usersResult.rows.length}\n`);
      
      usersResult.rows.forEach((user, index) => {
        console.log(`${index + 1}. ${user.username || 'N/A'}`);
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Role: ${user.role}`);
        console.log(`   Created: ${new Date(user.created_at).toLocaleString()}`);
        console.log(`   Stats: ${user.clothing_count} clothes, ${user.outfit_count} outfits, ${user.post_count} posts`);
        if (user.avatar_url) {
          console.log(`   Avatar: ${user.avatar_url}`);
        }
        console.log('');
      });
    }
    
    client.release();
    await pool.end();
    
  } catch (error) {
    console.error('❌ Error fetching users:', error.message);
    process.exit(1);
  }
}

listUsers();

