const db = require('../db');

async function addTitleColumn() {
  try {
    console.log('🔧 Adding title column to outfit_planning table if missing...');
    await db.query(`
      ALTER TABLE outfit_planning
      ADD COLUMN IF NOT EXISTS title TEXT
    `);
    console.log('✅ Column ensured.');
  } catch (error) {
    console.error('❌ Failed to add title column:', error);
  } finally {
    process.exit(0);
  }
}

addTitleColumn();

