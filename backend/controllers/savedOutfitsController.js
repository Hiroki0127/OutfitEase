const savedOutfitsModel = require('../models/savedOutfitsModel');

// Get saved outfits for a user
exports.getSavedOutfits = async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log("📚 Getting saved outfits for user:", userId);
    
    const savedOutfits = await savedOutfitsModel.getSavedOutfits(userId);
    console.log("✅ Found", savedOutfits.length, "saved outfits");
    
    res.json(savedOutfits);
  } catch (err) {
    console.error("Get saved outfits error:", err);
    res.status(500).json({ error: "Failed to get saved outfits" });
  }
};

// Save an outfit
exports.saveOutfit = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { outfitId } = req.params;
    
    console.log("💾 Saving outfit:", outfitId, "for user:", userId);
    
    const savedOutfit = await savedOutfitsModel.saveOutfit(userId, outfitId);
    console.log("✅ Outfit saved successfully");
    
    res.status(201).json(savedOutfit);
  } catch (err) {
    console.error("Save outfit error:", err);
    res.status(500).json({ error: "Failed to save outfit" });
  }
};

// Unsave an outfit
exports.unsaveOutfit = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { outfitId } = req.params;
    
    console.log("🗑️ Unsaving outfit:", outfitId, "for user:", userId);
    
    const unsavedOutfit = await savedOutfitsModel.unsaveOutfit(userId, outfitId);
    console.log("✅ Outfit unsaved successfully");
    
    res.json({ message: "Outfit unsaved successfully" });
  } catch (err) {
    console.error("Unsave outfit error:", err);
    res.status(500).json({ error: "Failed to unsave outfit" });
  }
};

// Check if an outfit is saved
exports.checkSavedStatus = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { outfitId } = req.params;
    
    const isSaved = await savedOutfitsModel.isOutfitSaved(userId, outfitId);
    
    res.json({ isSaved });
  } catch (err) {
    console.error("Check saved status error:", err);
    res.status(500).json({ error: "Failed to check saved status" });
  }
};

// Bulk unsave outfits
exports.bulkUnsaveOutfits = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { outfitIds } = req.body;
    
    console.log("🗑️ Bulk unsaving", outfitIds.length, "outfits for user:", userId);
    
    const unsavedOutfits = await savedOutfitsModel.bulkUnsaveOutfits(userId, outfitIds);
    console.log("✅ Bulk unsave completed");
    
    res.json({ 
      message: `${unsavedOutfits.length} outfits unsaved successfully`,
      unsavedCount: unsavedOutfits.length 
    });
  } catch (err) {
    console.error("Bulk unsave outfits error:", err);
    res.status(500).json({ error: "Failed to bulk unsave outfits" });
  }
};
