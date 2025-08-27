const db = require('../db');

async function verifyCleanup() {
  try {
    const outfits = await db.query('SELECT COUNT(*) as count FROM outfits WHERE user_id = $1', ['8b7fa489-9bdb-49f5-bcd9-143ce72624d0']);
    const saved = await db.query('SELECT COUNT(*) as count FROM saved_outfits WHERE user_id = $1', ['8b7fa489-9bdb-49f5-bcd9-143ce72624d0']);
    
    console.log('📊 Current state after cleanup:');
    console.log('   My Outfits: ' + outfits.rows[0].count);
    console.log('   Saved Outfits: ' + saved.rows[0].count);
    
    if (outfits.rows[0].count === 0) {
      console.log('\n✅ Perfect! Your "My Outfits" is now empty.');
      console.log('   This means all the incorrectly created outfits have been removed.');
    } else {
      console.log('\n📝 You still have ' + outfits.rows[0].count + ' outfits in "My Outfits".');
      console.log('   These should be outfits you actually created yourself.');
    }
    
    console.log('\n💾 Your "Saved Outfits" contains ' + saved.rows[0].count + ' outfits from the community.');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

verifyCleanup();
