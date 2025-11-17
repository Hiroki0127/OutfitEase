/**
 * Migration script to add parent_comment_id column to post_comments table
 * 
 * Run this locally with:
 * DATABASE_URL="your-supabase-connection-string" node backend/scripts/addParentCommentIdColumn.js
 * 
 * Or run the SQL directly in Supabase SQL Editor
 */

const db = require('../db');

async function addParentCommentIdColumn() {
  try {
    console.log('🔄 Adding parent_comment_id column to post_comments table...');
    
    // Check if column already exists
    const checkColumn = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'post_comments' 
      AND column_name = 'parent_comment_id'
    `);
    
    if (checkColumn.rows.length > 0) {
      console.log('✅ Column parent_comment_id already exists');
      process.exit(0);
    }
    
    // Add the column
    await db.query(`
      ALTER TABLE post_comments 
      ADD COLUMN parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE
    `);
    
    console.log('✅ Successfully added parent_comment_id column');
    
    // Create index for better query performance
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_post_comments_parent 
      ON post_comments(parent_comment_id)
    `);
    
    console.log('✅ Created index on parent_comment_id');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error adding column:', error);
    process.exit(1);
  }
}

addParentCommentIdColumn();

