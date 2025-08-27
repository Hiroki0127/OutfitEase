const likesModel = require('../models/likesModel');

exports.likePost = async (req, res) => {
  const userId = req.user.userId;
  const { postId } = req.params;

  try {
    const like = await likesModel.likePost(userId, postId);
    if (!like) return res.status(200).json({ message: 'Already liked' });
    res.status(201).json(like);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to like post' });
  }
};

exports.unlikePost = async (req, res) => {
  const { postId } = req.params; // postId
  const userId = req.user.userId;

  try {
    console.log('Trying to delete like with userId:', userId, 'and postId:', postId);

    const removed = await likesModel.unlikePost(userId, postId);
    if (!removed) {
      return res.status(404).json({ error: 'Like not found' });
    }
    res.json({ message: 'Like removed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to remove like' });
  }
};

exports.getLikesCount = async (req, res) => {
  const { postId } = req.params;

  try {
    const count = await likesModel.getLikesCount(postId);
    res.json({ likes: count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch likes count' });
  }
};

// Outfit likes
exports.likeOutfit = async (req, res) => {
  const userId = req.user.userId;
  const { outfitId } = req.params;

  try {
    const like = await likesModel.likeOutfit(userId, outfitId);
    if (!like) return res.status(200).json({ message: 'Already liked' });
    res.status(201).json(like);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to like outfit' });
  }
};

exports.unlikeOutfit = async (req, res) => {
  const { outfitId } = req.params;
  const userId = req.user.userId;

  try {
    const removed = await likesModel.unlikeOutfit(userId, outfitId);
    if (!removed) {
      return res.status(404).json({ error: 'Like not found' });
    }
    res.json({ message: 'Like removed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to remove like' });
  }
};

exports.getOutfitLikesCount = async (req, res) => {
  const { outfitId } = req.params;

  try {
    const count = await likesModel.getOutfitLikesCount(outfitId);
    res.json({ likes: count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch likes count' });
  }
};

// Get liked content
exports.getLikedPosts = async (req, res) => {
  const userId = req.user.userId;

  try {
    const likedPosts = await likesModel.getLikedPosts(userId);
    res.json(likedPosts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch liked posts' });
  }
};

exports.getLikedOutfits = async (req, res) => {
  const userId = req.user.userId;

  try {
    const likedOutfits = await likesModel.getLikedOutfits(userId);
    res.json(likedOutfits);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch liked outfits' });
  }
};
