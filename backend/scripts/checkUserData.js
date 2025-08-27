const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function checkUserData() {
  try {
    const client = await pool.connect();
    
    // Test user ID from your logs
    const testUserId = '284a936e-6c26-455c-bf38-72887c76a0c5';
    
    console.log('🔍 Checking data for test user:', testUserId);
    console.log('=' .repeat(50));
    
    // Check outfits
    const outfitsResult = await client.query(
      'SELECT id, name, description, total_price, created_at FROM outfits WHERE user_id = $1 ORDER BY created_at DESC',
      [testUserId]
    );
    
    console.log(`📦 Outfits (${outfitsResult.rows.length}):`);
    outfitsResult.rows.forEach((outfit, index) => {
      console.log(`  ${index + 1}. ${outfit.name || 'Untitled'} - $${outfit.total_price || 0} (${outfit.created_at})`);
    });
    
    console.log('');
    
    // Check clothes
    const clothesResult = await client.query(
      'SELECT id, name, type, color, brand, price, created_at FROM clothing_items WHERE user_id = $1 ORDER BY created_at DESC',
      [testUserId]
    );
    
    console.log(`👕 Clothes (${clothesResult.rows.length}):`);
    clothesResult.rows.forEach((item, index) => {
      console.log(`  ${index + 1}. ${item.name || 'Untitled'} - ${item.type} - $${item.price || 0} (${item.created_at})`);
    });
    
    console.log('');
    
    // Check outfit plans
    const plansResult = await client.query(
      'SELECT id, outfit_id, planned_date FROM outfit_planning WHERE user_id = $1 ORDER BY planned_date DESC',
      [testUserId]
    );
    
    console.log(`📅 Outfit Plans (${plansResult.rows.length}):`);
    plansResult.rows.forEach((plan, index) => {
      console.log(`  ${index + 1}. Outfit ID: ${plan.outfit_id} - Date: ${plan.planned_date}`);
    });
    
    client.release();
    await pool.end();
    
  } catch (error) {
    console.error('Error checking user data:', error);
  }
}

checkUserData(); 