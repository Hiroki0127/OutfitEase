const db = require('../db');

exports.createOutfit = async (userId, name, description, totalPrice, imageURL, style, color, brand, season, occasion, clothingItemIds) => {

  
  const outfitRes = await db.query(
    `INSERT INTO outfits (user_id, name, description, total_price, image_url, style, color, brand, season, occasion)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
    [userId, name, description, totalPrice, imageURL, style, color, brand, season, occasion]
  );

  const outfitId = outfitRes.rows[0].id;

  // Check if clothingItemIds is an array and has items
  if (clothingItemIds && Array.isArray(clothingItemIds) && clothingItemIds.length > 0) {
    for (const itemId of clothingItemIds) {
      await db.query(
        `INSERT INTO outfit_items (outfit_id, clothing_item_id)
         VALUES ($1, $2)`,
        [outfitId, itemId]
      );
    }
  }

  return outfitRes.rows[0];
};

exports.getAllOutfitsForUser = async (userId) => {
  const result = await db.query(
    `SELECT * FROM outfits WHERE user_id = $1 ORDER BY created_at DESC`,
    [userId]
  );
  return result.rows;
};

exports.getOutfitById = async (id, userId) => {
  const outfitRes = await db.query(
    `SELECT * FROM outfits WHERE id = $1 AND user_id = $2`,
    [id, userId]
  );

  if (outfitRes.rows.length === 0) return null;

  const itemsRes = await db.query(
    `SELECT c.* FROM outfit_items oi
     JOIN clothing_items c ON c.id = oi.clothing_item_id
     WHERE oi.outfit_id = $1`,
    [id]
  );

  return {
    ...outfitRes.rows[0],
    items: itemsRes.rows
  };
};


exports.updateOutfit = async (
  outfitId,
  userId,
  name,
  description,
  totalPrice,
  imageURL,
  style,
  color,
  brand,
  season,
  occasion,
  clothingItemIds
) => {
  const client = await db.connect();

  try {
    await client.query('BEGIN');

    const updateQuery = `
      UPDATE outfits
      SET
        name = $1,
        description = $2,
        total_price = $3,
        image_url = $4,
        style = $5,
        color = $6,
        brand = $7,
        season = $8,
        occasion = $9
      WHERE id = $10 AND user_id = $11
      RETURNING *;
    `;

    const updateValues = [
      name,
      description,
      totalPrice,
      imageURL,
      style,
      color,
      brand,
      season,
      occasion,
      outfitId,
      userId
    ];

    const result = await client.query(updateQuery, updateValues);

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return null;
    }

    if (clothingItemIds && clothingItemIds.length > 0) {
      await client.query(
        'DELETE FROM outfit_items WHERE outfit_id = $1',
        [outfitId]
      );

      for (const itemId of clothingItemIds) {
        await client.query(
          'INSERT INTO outfit_items (outfit_id, clothing_item_id) VALUES ($1, $2)',
          [outfitId, itemId]
        );
      }
    }

    await client.query('COMMIT');
    return result.rows[0];
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

exports.deleteOutfit = async (id, userId) => {
  await db.query(`DELETE FROM outfit_items WHERE outfit_id = $1`, [id]);
  const result = await db.query(`DELETE FROM outfits WHERE id = $1 AND user_id = $2`, [id, userId]);
  return result;
};

// ✅ Bulk delete multiple outfits
exports.bulkDeleteOutfits = async (outfitIds, userId) => {
  try {
    if (outfitIds.length === 0) {
      return 0;
    }
    
    let deletedCount = 0;
    
    // Delete outfits one by one to avoid parameter type issues
    for (const outfitId of outfitIds) {
      try {
        // First delete outfit_items for this outfit
        await db.query(`DELETE FROM outfit_items WHERE outfit_id = $1`, [outfitId]);
        
        // Then delete the outfit
        const result = await db.query(`DELETE FROM outfits WHERE id = $1 AND user_id = $2`, [outfitId, userId]);
        
        if (result.rowCount > 0) {
          deletedCount++;
        }
      } catch (err) {
        console.error(`Error deleting outfit ${outfitId}:`, err);
        // Continue with other outfits even if one fails
      }
    }
    
    console.log(`Bulk deleted outfits count: ${deletedCount}`);
    return deletedCount;
  } catch (err) {
    console.error('Error in bulkDeleteOutfits:', err);
    throw err;
  }
};

exports.getFilteredOutfits = async (userId, filters) => {
  const { style, color, brand, season, occasion, minPrice, maxPrice, search } = filters;
  let baseQuery = `SELECT * FROM outfits WHERE user_id = $1`;
  const params = [userId];
  let idx = 2;

  if (style) {
    baseQuery += ` AND style @> ARRAY[$${idx}::text]`;
    params.push(style.toLowerCase());
    idx++;
  }

  if (color) {
    baseQuery += ` AND color @> ARRAY[$${idx}::text]`;
    params.push(color.toLowerCase());
    idx++;
  }

  if (brand) {
    baseQuery += ` AND brand @> ARRAY[$${idx}::text]`;
    params.push(brand.toLowerCase());
    idx++;
  }

  if (season) {
    baseQuery += ` AND season @> ARRAY[$${idx}::text]`;
    params.push(season.toLowerCase());
    idx++;
  }

  if (occasion) {
    baseQuery += ` AND occasion @> ARRAY[$${idx}::text]`;
    params.push(occasion.toLowerCase());
    idx++;
  }

  if (minPrice) {
    baseQuery += ` AND total_price >= $${idx++}`;
    params.push(minPrice);
  }

  if (maxPrice) {
    baseQuery += ` AND total_price <= $${idx++}`;
    params.push(maxPrice);
  }

  if (search) {
    baseQuery += ` AND (name ILIKE $${idx} OR description ILIKE $${idx})`;
    params.push(`%${search}%`);
    idx++;
  }

  baseQuery += ' ORDER BY created_at DESC';

  const result = await db.query(baseQuery, params);
  return result.rows;
};
