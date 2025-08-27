const db = require('../db');

async function cleanupOutfits() {
  try {
    console.log('🔍 Analyzing outfits for user...');
    
    // Get all outfits for the user
    const outfitsResult = await db.query(
      'SELECT * FROM outfits WHERE user_id = $1 ORDER BY created_at DESC',
      ['8b7fa489-9bdb-49f5-bcd9-143ce72624d0'] // Your user ID
    );
    
    console.log(`📊 Found ${outfitsResult.rows.length} total outfits`);
    
    // Get saved outfits for the user
    const savedOutfitsResult = await db.query(
      'SELECT outfit_id FROM saved_outfits WHERE user_id = $1',
      ['8b7fa489-9bdb-49f5-bcd9-143ce72624d0']
    );
    
    const savedOutfitIds = savedOutfitsResult.rows.map(row => row.outfit_id);
    console.log(`💾 Found ${savedOutfitIds.length} saved outfit references`);
    
    // Identify outfits that are NOT in saved_outfits (these are the incorrectly created ones)
    const incorrectlyCreatedOutfits = outfitsResult.rows.filter(outfit => 
      !savedOutfitIds.includes(outfit.id)
    );
    
    console.log(`\n🗑️ Found ${incorrectlyCreatedOutfits.length} outfits that were incorrectly created:`);
    incorrectlyCreatedOutfits.forEach((outfit, index) => {
      console.log(`${index + 1}. ${outfit.name || 'Untitled'} (ID: ${outfit.id})`);
      console.log(`   Description: ${outfit.description || 'No description'}`);
      console.log(`   Created: ${outfit.created_at}`);
      console.log(`   Price: $${outfit.total_price || 'N/A'}`);
    });
    
    if (incorrectlyCreatedOutfits.length > 0) {
      console.log('\n🧹 Cleaning up incorrectly created outfits...');
      
      for (const outfit of incorrectlyCreatedOutfits) {
        try {
          // Delete in the correct order to handle foreign key constraints
          
          // 1. Delete from outfit_planning first
          await db.query('DELETE FROM outfit_planning WHERE outfit_id = $1', [outfit.id]);
          console.log(`   - Removed from outfit planning`);
          
          // 2. Delete from outfit_items
          await db.query('DELETE FROM outfit_items WHERE outfit_id = $1', [outfit.id]);
          console.log(`   - Removed outfit items`);
          
          // 3. Delete from posts (if any)
          await db.query('DELETE FROM posts WHERE outfit_id = $1', [outfit.id]);
          console.log(`   - Removed from posts`);
          
          // 4. Finally delete the outfit
          await db.query('DELETE FROM outfits WHERE id = $1 AND user_id = $2', [outfit.id, '8b7fa489-9bdb-49f5-bcd9-143ce72624d0']);
          
          console.log(`✅ Deleted: ${outfit.name || 'Untitled'} (${outfit.id})`);
        } catch (error) {
          console.log(`❌ Error deleting ${outfit.name}: ${error.message}`);
        }
      }
      
      console.log('\n🎉 Cleanup completed!');
      console.log('Your "My Outfits" should now only show outfits you actually created.');
      console.log('Your "Saved Outfits" will show outfits you saved from the community.');
    } else {
      console.log('\n✅ No cleanup needed - all outfits are properly organized!');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

cleanupOutfits();
