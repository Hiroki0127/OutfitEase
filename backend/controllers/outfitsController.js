const outfitsModel = require('../models/outfitsModel');

exports.createOutfit = async (req, res) => {
  const userId = req.user.userId;
  const { 
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
  } = req.body;
  
  console.log('📝 Creating outfit with imageURL:', imageURL);
  
  try {
    const outfit = await outfitsModel.createOutfit(
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
    );

    res.status(201).json(outfit);
  } catch (err) {
    console.error("Create outfit error:", err);
    res.status(500).json({ error: "Failed to create outfit" });
  }
};

const pool = require('../db');

exports.getAllOutfits = async (req, res) => {
  const { userId } = req.user;
  const { name, style, color, brand, season, occasion, minPrice, maxPrice, search } = req.query;

  let baseQuery = `SELECT * FROM outfits WHERE user_id = $1`;
  const params = [userId];
  let paramIdx = 2;

  if (name) {
    baseQuery += ` AND name ILIKE $${paramIdx++}`;
    params.push(`%${name}%`);
  }

  if (style) {
  baseQuery += ` AND EXISTS (SELECT 1 FROM unnest(style) s WHERE LOWER(s) = LOWER($${paramIdx}))`;
  params.push(style);
  paramIdx++;
  }

  if (color) {
    baseQuery += ` AND EXISTS (SELECT 1 FROM unnest(color) c WHERE LOWER(c) = LOWER($${paramIdx}))`;
    params.push(color);
    paramIdx++;
  }

  if (brand) {
    baseQuery += ` AND EXISTS (SELECT 1 FROM unnest(brand) b WHERE LOWER(b) = LOWER($${paramIdx}))`;
    params.push(brand);
    paramIdx++;
  }


  if (season) {
    baseQuery += ` AND season @> ARRAY[$${paramIdx}::text[]]`;
    params.push(Array.isArray(season) ? season : [season.toLowerCase()]);
    paramIdx++;
  }

  if (occasion) {
    baseQuery += ` AND occasion @> ARRAY[$${paramIdx}::text[]]`;
    params.push(Array.isArray(occasion) ? occasion : [occasion.toLowerCase()]);
    paramIdx++;
  }

  if (minPrice) {
    baseQuery += ` AND total_price >= $${paramIdx++}`;
    params.push(minPrice);
  }

  if (maxPrice) {
    baseQuery += ` AND total_price <= $${paramIdx++}`;
    params.push(maxPrice);
  }

  if (search) {
    baseQuery += ` AND (name ILIKE $${paramIdx} OR description ILIKE $${paramIdx})`;
    params.push(`%${search}%`);
    paramIdx++;
  }

  baseQuery += ` ORDER BY created_at DESC`;

  try {
    const result = await pool.query(baseQuery, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Error filtering outfits:', err);
    res.status(500).json({ error: 'Failed to fetch outfits' });
  }
};



exports.getOutfitById = async (req, res) => {
  try {
    const outfit = await outfitsModel.getOutfitById(req.params.id, req.user.userId);
    if (!outfit) return res.status(404).json({ error: "Outfit not found" });
    res.json(outfit);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch outfit" });
  }
};

exports.updateOutfit = async (req, res) => {
  try {
    const {
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
    } = req.body;

    console.log('📝 Updating outfit:', req.params.id);
    console.log('📸 Image URL:', imageURL);

    const updated = await outfitsModel.updateOutfit(
      req.params.id,
      req.user.userId,
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
    );

    if (!updated) {
      return res.status(404).json({ error: "Outfit not found" });
    }

    res.json(updated);
  } catch (err) {
    console.error("Failed to update outfit:", err);
    console.error("Error details:", {
      message: err.message,
      stack: err.stack,
      code: err.code,
      name: err.name
    });
    res.status(500).json({ 
      error: "Failed to update outfit",
      details: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};


exports.deleteOutfit = async (req, res) => {
  try {
    console.log('🗑️ Deleting outfit:', req.params.id, 'for user:', req.user.userId);
    const result = await outfitsModel.deleteOutfit(req.params.id, req.user.userId);
    
    if (result && result.rowCount > 0) {
      console.log('✅ Outfit deleted successfully');
      res.json({ message: "Outfit deleted successfully" });
    } else {
      console.log('❌ Outfit not found or not owned by user');
      res.status(404).json({ error: "Outfit not found or you don't have permission to delete it" });
    }
  } catch (err) {
    console.error('❌ Failed to delete outfit:', err);
    res.status(500).json({ error: "Failed to delete outfit" });
  }
};

// ✅ Bulk delete multiple outfits
exports.bulkDeleteOutfits = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { outfitIds } = req.body;

    if (!outfitIds || !Array.isArray(outfitIds) || outfitIds.length === 0) {
      return res.status(400).json({ error: 'Outfit IDs array is required' });
    }

    const deletedCount = await outfitsModel.bulkDeleteOutfits(outfitIds, userId);
    
    console.log(`✅ Bulk deleted ${deletedCount} outfits successfully`);
    res.json({ 
      message: `Successfully deleted ${deletedCount} outfits`,
      deletedCount 
    });
  } catch (err) {
    console.error('❌ Failed to bulk delete outfits:', err);
    res.status(500).json({ error: 'Failed to delete outfits' });
  }
};
