const db = require('../db'); 
const clothesModel = require('../models/clothesModel');

// ✅ Create clothing item, linked to logged-in user
exports.createClothingItem = async (req, res) => {
  try {
    const userId = req.user.userId;  // comes from auth JWT middleware
    const { name, type, color, style, brand, price, season, occasion, image_url } = req.body;

    const result = await clothesModel.create(userId, {
      name, type, color, style, brand, price, season, occasion, image_url
    });

    // Format the response to match iOS expectations
    const formattedItem = {
      id: result.id.toString(), // Convert UUID to string
      user_id: result.user_id,
      name: result.name,
      type: result.type,
      color: result.color,
      style: result.style,
      brand: result.brand,
      price: result.price ? parseFloat(result.price) : null, // Convert string to number
      season: result.season,
      occasion: result.occasion,
      image_url: result.image_url,
      created_at: result.created_at
    };

    res.status(201).json(formattedItem);
  } catch (err) {
    console.error('Error creating clothing item:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getClothingItems = async (req, res) => {
  try {
    const userId = req.user.userId;
    const filters = {
      type: req.query.type,
      color: req.query.color,
      style: req.query.style,
      brand: req.query.brand,
      season: req.query.season,
      occasion: req.query.occasion,
      minPrice: req.query.minPrice,
      maxPrice: req.query.maxPrice,
    };

    // If any filter is set, call filtered method
    const anyFilterSet = Object.values(filters).some(v => v !== undefined && v !== null);

    const items = anyFilterSet
      ? await clothesModel.getFilteredClothingItems(userId, filters)
      : await clothesModel.getByUserId(userId);

    res.json(items);
  } catch (err) {
    console.error('Error fetching clothing items:', err);
    res.status(500).json({ error: 'Failed to fetch clothing items' });
  }
};



exports.updateClothingItem = async (req, res) => {
  try {
    const updated = await clothesModel.update(req.params.id, req.user.userId, req.body);
    if (!updated) return res.status(404).json({ error: 'Clothing item not found' });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update clothing item' });
  }
};

exports.deleteClothingItem = async (req, res) => {
  try {
    await clothesModel.remove(req.params.id, req.user.userId);
    res.json({ message: "Clothing item deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete clothing item' });
  }
};

// ✅ Bulk delete multiple clothing items
exports.bulkDeleteClothingItems = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { itemIds } = req.body;

    if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ error: 'Item IDs array is required' });
    }

    const deletedCount = await clothesModel.bulkRemove(itemIds, userId);
    
    res.json({ 
      message: `Successfully deleted ${deletedCount} clothing items`,
      deletedCount 
    });
  } catch (err) {
    console.error('Error in bulk delete:', err);
    res.status(500).json({ error: 'Failed to delete clothing items' });
  }
};


// ✅ Optional: get single item by id (public, maybe?)
exports.getClothingItemById = async (req, res) => {
  const id = req.params.id;
  try {
    const result = await db.query(
      'SELECT * FROM clothing_items WHERE id = $1', 
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Format the response to match iOS expectations
    const item = result.rows[0];
    const formattedItem = {
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
    };
    
    res.json(formattedItem);
  } catch (err) {
    console.error("Database error:", err);
    res.status(500).json({ error: 'Server error' });
  }
};

