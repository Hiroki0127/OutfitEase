const db = require('../db.js');

exports.create = async (userId, data) => {
  try {
    const { name, type, color, style, brand, price, season, occasion, image_url } = data;
    const result = await db.query(
      `INSERT INTO clothing_items 
       (user_id, name, type, color, style, brand, price, season, occasion, image_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [userId, name, type, color, style, brand, price, season, occasion, image_url]
    );
    return result.rows[0];
  } catch (err) {
    console.error('Error in create:', err);
    throw err;
  }
};

exports.getByUserId = async (userId) => {
  try {
    const result = await db.query(
      `SELECT * FROM clothing_items WHERE user_id = $1 ORDER BY created_at DESC`,
      [userId]
    );
    
    // Format the response to match iOS expectations
    return result.rows.map(item => ({
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
  } catch (err) {
    console.error('Error in getByUserId:', err);
    throw err;
  }
};

exports.update = async (id, userId, data) => {
  try {
    const { name, type, color, style, brand, price, season, occasion, image_url } = data;
    console.log('Update called with:', { id, userId, data });

    const result = await db.query(
      `UPDATE clothing_items
       SET name = $1, type = $2, color = $3, style = $4, brand = $5, price = $6, season = $7, occasion = $8, image_url = $9
       WHERE id = $10 AND user_id = $11
       RETURNING *`,
      [name, type, color, style, brand, price, season, occasion, image_url, id, userId]
    );

    console.log('Update result:', result.rows);
    
    if (result.rows[0]) {
      // Format the response to match iOS expectations
      const item = result.rows[0];
      return {
        id: item.id.toString(), // Convert UUID to string
        user_id: item.user_id,
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
      };
    }
    return null;
  } catch (err) {
    console.error('Error in update:', err);
    throw err;
  }
};

exports.remove = async (id, userId) => {
  try {
    const result = await db.query(
      `DELETE FROM clothing_items WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    console.log(`Deleted rows count: ${result.rowCount}`);
  } catch (err) {
    console.error('Error in remove:', err);
    throw err;
  }
};

// ✅ Bulk remove multiple clothing items
exports.bulkRemove = async (itemIds, userId) => {
  try {
    // Use parameterized query with placeholders for each ID
    const placeholders = itemIds.map((_, index) => `$${index + 2}`).join(',');
    const query = `
      DELETE FROM clothing_items 
      WHERE id IN (${placeholders}) AND user_id = $1
    `;
    
    const params = [userId, ...itemIds];
    const result = await db.query(query, params);
    
    console.log(`Bulk deleted rows count: ${result.rowCount}`);
    return result.rowCount;
  } catch (err) {
    console.error('Error in bulkRemove:', err);
    throw err;
  }
};


exports.getFilteredClothingItems = async (userId, filters) => {
  try {
    let baseQuery = `SELECT * FROM clothing_items WHERE user_id = $1`;
    const params = [userId];
    let idx = 2;

    if (filters.type) {
      baseQuery += ` AND type ILIKE $${idx++}`;
      params.push(`%${filters.type}%`);
    }
    if (filters.color) {
      baseQuery += ` AND color ILIKE $${idx++}`;
      params.push(`%${filters.color}%`);
    }
    if (filters.style) {
      baseQuery += ` AND style ILIKE $${idx++}`;
      params.push(`%${filters.style}%`);
    }
    if (filters.brand) {
      baseQuery += ` AND brand ILIKE $${idx++}`;
      params.push(`%${filters.brand}%`);
    }
    if (filters.season) {
      baseQuery += ` AND season && $${idx++}`;
      params.push([filters.season]);
    }
    if (filters.occasion) {
      baseQuery += ` AND occasion && $${idx++}`;
      params.push([filters.occasion]);
    }
    if (filters.minPrice) {
      baseQuery += ` AND price >= $${idx++}`;
      params.push(filters.minPrice);
    }
    if (filters.maxPrice) {
      baseQuery += ` AND price <= $${idx++}`;
      params.push(filters.maxPrice);
    }

    baseQuery += ` ORDER BY created_at DESC`;

    const result = await db.query(baseQuery, params);
    
    // Format the response to match iOS expectations
    return result.rows.map(item => ({
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
  } catch (err) {
    console.error('Error in getFilteredClothingItems:', err);
    throw err;
  }
};
