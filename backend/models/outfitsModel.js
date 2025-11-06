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
  
  // For each outfit, get its clothing items
  const outfitsWithItems = await Promise.all(
    result.rows.map(async (outfit) => {
      const itemsRes = await db.query(
        `SELECT c.* FROM outfit_items oi
         JOIN clothing_items c ON c.id = oi.clothing_item_id
         WHERE oi.outfit_id = $1`,
        [outfit.id]
      );
      
      // Format clothing items to match iOS expectations
      const formattedItems = itemsRes.rows.map(item => ({
        id: item.id.toString(), // Convert UUID to string
        user_id: item.user_id.toString(),
        name: item.name,
        type: item.type,
        color: item.color,
        style: item.style,
        brand: item.brand,
        price: item.price ? parseFloat(item.price) : null, // Convert string to number
        // Convert season and occasion strings to arrays (iOS expects arrays)
        season: item.season ? [item.season] : null,
        occasion: item.occasion ? [item.occasion] : null,
        image_url: item.image_url,
        created_at: item.created_at
      }));
      
      return {
        ...outfit,
        items: formattedItems
      };
    })
  );
  
  return outfitsWithItems;
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

  // Format clothing items to match iOS expectations
  const formattedItems = itemsRes.rows.map(item => ({
    id: item.id.toString(), // Convert UUID to string
    user_id: item.user_id,
    name: item.name,
    type: item.type,
    color: item.color,
    style: item.style,
    brand: item.brand,
    price: item.price ? parseFloat(item.price) : null, // Convert string to number
    season: item.season,
    occasion: item.occasion,
    image_url: item.image_url,
    created_at: item.created_at
  }));

  return {
    ...outfitRes.rows[0],
    items: formattedItems
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

    console.log('📝 Updating outfit in database:', {
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
    });

    const updateQuery = `
      UPDATE outfits
      SET
        name = COALESCE($1, name),
        description = COALESCE($2, description),
        total_price = COALESCE($3, total_price),
        image_url = COALESCE($4, image_url),
        style = COALESCE($5, style),
        color = COALESCE($6, color),
        brand = COALESCE($7, brand),
        season = COALESCE($8, season),
        occasion = COALESCE($9, occasion)
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
    
    // Return the complete outfit with clothing items
    const itemsRes = await client.query(
      `SELECT c.* FROM outfit_items oi
       JOIN clothing_items c ON c.id = oi.clothing_item_id
       WHERE oi.outfit_id = $1`,
      [outfitId]
    );

    // Format clothing items to match iOS expectations
    const formattedItems = itemsRes.rows.map(item => ({
      id: item.id.toString(), // Convert UUID to string
      user_id: item.user_id.toString(),
      name: item.name,
      type: item.type,
      color: item.color,
      style: item.style,
      brand: item.brand,
      price: item.price ? parseFloat(item.price) : null, // Convert string to number
      // Convert season and occasion strings to arrays (iOS expects arrays)
      season: item.season ? [item.season] : null,
      occasion: item.occasion ? [item.occasion] : null,
      image_url: item.image_url,
      created_at: item.created_at
    }));

    return {
      ...result.rows[0],
      items: formattedItems
    };
  } catch (err) {
    await client.query('ROLLBACK').catch(rollbackErr => {
      console.error('Error during rollback:', rollbackErr);
    });
    console.error('❌ Error updating outfit:', err);
    console.error('Error details:', {
      message: err.message,
      stack: err.stack,
      code: err.code,
      name: err.name
    });
    throw err;
  } finally {
    client.release();
  }
};

exports.deleteOutfit = async (id, userId) => {
  try {
    console.log(`🗑️ Deleting outfit ${id} for user ${userId}`);
    
    // Delete from saved_outfits first (no CASCADE)
    await db.query(`DELETE FROM saved_outfits WHERE outfit_id = $1`, [id]);
    console.log(`✅ Deleted from saved_outfits`);
    
    // Delete from outfit_planning (no CASCADE)
    await db.query(`DELETE FROM outfit_planning WHERE outfit_id = $1`, [id]);
    console.log(`✅ Deleted from outfit_planning`);
    
    // Delete from outfit_items (has CASCADE but being explicit)
    await db.query(`DELETE FROM outfit_items WHERE outfit_id = $1`, [id]);
    console.log(`✅ Deleted from outfit_items`);
    
    // Delete from posts (has CASCADE but being explicit)
    await db.query(`DELETE FROM posts WHERE outfit_id = $1`, [id]);
    console.log(`✅ Deleted from posts`);
    
    // Finally delete the outfit
    const result = await db.query(`DELETE FROM outfits WHERE id = $1 AND user_id = $2`, [id, userId]);
    console.log(`✅ Deleted outfit, rows affected: ${result.rowCount}`);
    
    return result;
  } catch (err) {
    console.error(`❌ Error deleting outfit ${id}:`, err);
    throw err;
  }
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
        console.log(`🗑️ Bulk deleting outfit ${outfitId} for user ${userId}`);
        
        // Delete from saved_outfits first (no CASCADE)
        await db.query(`DELETE FROM saved_outfits WHERE outfit_id = $1`, [outfitId]);
        
        // Delete from outfit_planning (no CASCADE)
        await db.query(`DELETE FROM outfit_planning WHERE outfit_id = $1`, [outfitId]);
        
        // Delete from outfit_items (has CASCADE but being explicit)
        await db.query(`DELETE FROM outfit_items WHERE outfit_id = $1`, [outfitId]);
        
        // Delete from posts (has CASCADE but being explicit)
        await db.query(`DELETE FROM posts WHERE outfit_id = $1`, [outfitId]);
        
        // Finally delete the outfit
        const result = await db.query(`DELETE FROM outfits WHERE id = $1 AND user_id = $2`, [outfitId, userId]);
        
        if (result.rowCount > 0) {
          deletedCount++;
          console.log(`✅ Successfully deleted outfit ${outfitId}`);
        }
      } catch (err) {
        console.error(`❌ Error deleting outfit ${outfitId}:`, err);
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
