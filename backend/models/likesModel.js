const db = require('../db');

// Like a post
async function likePost(userId, postId) {
  const result = await db.query(
    'INSERT INTO post_likes (user_id, post_id) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING *',
    [userId, postId]
  );
  return result.rows[0];
}

// Unlike a post
async function unlikePost(userId, postId) {
  const result = await db.query(
    'DELETE FROM post_likes WHERE user_id = $1 AND post_id = $2 RETURNING *',
    [userId, postId]
  );
  return result.rows[0];
}

// Count likes on a post
async function getLikesCount(postId) {
  const result = await db.query(
    'SELECT COUNT(*) FROM post_likes WHERE post_id = $1',
    [postId]
  );
  return parseInt(result.rows[0].count);
}

// Like an outfit
async function likeOutfit(userId, outfitId) {
  const result = await db.query(
    'INSERT INTO outfit_likes (user_id, outfit_id) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING *',
    [userId, outfitId]
  );
  return result.rows[0];
}

// Unlike an outfit
async function unlikeOutfit(userId, outfitId) {
  const result = await db.query(
    'DELETE FROM outfit_likes WHERE user_id = $1 AND outfit_id = $2 RETURNING *',
    [userId, outfitId]
  );
  return result.rows[0];
}

// Count likes on an outfit
async function getOutfitLikesCount(outfitId) {
  const result = await db.query(
    'SELECT COUNT(*) FROM outfit_likes WHERE outfit_id = $1',
    [outfitId]
  );
  return parseInt(result.rows[0].count);
}

// Get liked posts for a user
async function getLikedPosts(userId) {
  const result = await db.query(`
    SELECT p.*, u.username, u.avatar_url, o.name as outfit_name, o.image_url as outfit_image_url,
           (SELECT COUNT(*) FROM post_likes WHERE post_id = p.id)::integer as likes_count,
           (SELECT COUNT(*) FROM post_comments WHERE post_id = p.id)::integer as comments_count
    FROM posts p
    JOIN users u ON p.user_id = u.id
    LEFT JOIN outfits o ON p.outfit_id = o.id
    JOIN post_likes pl ON p.id = pl.post_id
    WHERE pl.user_id = $1
    ORDER BY p.created_at DESC
  `, [userId]);
  return result.rows;
}

// Get liked outfits for a user (including user's own outfits)
async function getLikedOutfits(userId) {
  const result = await db.query(`
    SELECT o.*, u.username, u.avatar_url,
           (SELECT COUNT(*) FROM outfit_likes WHERE outfit_id = o.id)::integer as likes_count
    FROM outfits o
    JOIN users u ON o.user_id = u.id
    JOIN outfit_likes ol ON o.id = ol.outfit_id
    WHERE ol.user_id = $1
    ORDER BY o.created_at DESC
  `, [userId]);
  return result.rows;
}

module.exports = { 
  likePost, 
  unlikePost, 
  getLikesCount,
  likeOutfit,
  unlikeOutfit,
  getOutfitLikesCount,
  getLikedPosts,
  getLikedOutfits
};
