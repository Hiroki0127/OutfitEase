const db = require('../db');

// Save an outfit
async function saveOutfit(userId, outfitId) {
  const result = await db.query(
    'INSERT INTO saved_outfits (user_id, outfit_id) VALUES ($1, $2) ON CONFLICT (user_id, outfit_id) DO NOTHING RETURNING *',
    [userId, outfitId]
  );
  return result.rows[0];
}

// Unsave an outfit
async function unsaveOutfit(userId, outfitId) {
  const result = await db.query(
    'DELETE FROM saved_outfits WHERE user_id = $1 AND outfit_id = $2 RETURNING *',
    [userId, outfitId]
  );
  return result.rows[0];
}

// Check if an outfit is saved by a user
async function isOutfitSaved(userId, outfitId) {
  const result = await db.query(
    'SELECT EXISTS(SELECT 1 FROM saved_outfits WHERE user_id = $1 AND outfit_id = $2)',
    [userId, outfitId]
  );
  return result.rows[0].exists;
}

// Get saved outfits for a user
async function getSavedOutfits(userId) {
  const result = await db.query(`
    SELECT o.*, u.username, u.avatar_url,
           0 as likes_count,
           s.saved_at
    FROM outfits o
    JOIN users u ON o.user_id = u.id
    JOIN saved_outfits s ON o.id = s.outfit_id
    WHERE s.user_id = $1
    ORDER BY s.saved_at DESC
  `, [userId]);
  
  // For each outfit, get its clothing items
  const outfitsWithItems = await Promise.all(
    result.rows.map(async (outfit) => {
      const itemsRes = await db.query(
        `SELECT c.* FROM outfit_items oi
         JOIN clothing_items c ON c.id = oi.clothing_item_id
         WHERE oi.outfit_id = $1`,
        [outfit.id]
      );
      
      return {
        ...outfit,
        items: itemsRes.rows
      };
    })
  );
  
  return outfitsWithItems;
}

// Bulk unsave outfits
async function bulkUnsaveOutfits(userId, outfitIds) {
  const result = await db.query(
    'DELETE FROM saved_outfits WHERE user_id = $1 AND outfit_id = ANY($2) RETURNING *',
    [userId, outfitIds]
  );
  return result.rows;
}

module.exports = {
  saveOutfit,
  unsaveOutfit,
  isOutfitSaved,
  getSavedOutfits,
  bulkUnsaveOutfits
};
