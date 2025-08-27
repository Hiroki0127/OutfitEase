const planningModel = require('../models/planningModel');

exports.getAllPlanning = async (req, res) => {
  try {
    const plans = await planningModel.getAllForUser(req.user.userId);
    console.log("📅 Returning plans:", JSON.stringify(plans, null, 2));
    res.json(plans);
  } catch (err) {
    console.error("Fetch planning error:", err);
    res.status(500).json({ error: "Failed to fetch planning" });
  }
};

exports.createPlanning = async (req, res) => {
  try {
    const { outfitId, plannedDate, title } = req.body;
    console.log("📅 Creating planning:", { outfitId, plannedDate, title, userId: req.user.userId });
    const plan = await planningModel.create(req.user.userId, outfitId, plannedDate, title || null);
    console.log("✅ Created plan:", plan);
    res.status(201).json(plan);
  } catch (err) {
    console.error("Create planning error:", err);
    res.status(500).json({ error: "Failed to create planning" });
  }
};

exports.deletePlanning = async (req, res) => {
  try {
    await planningModel.remove(req.params.id, req.user.userId);
    res.status(204).send();
  } catch (err) {
    console.error("Delete planning error:", err);
    res.status(500).json({ error: "Failed to delete planning" });
  }
};
