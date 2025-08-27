const db = require('../db');

// Define the createPost function
async function createPost(userId, outfitId, caption, description, image_url) {
  const result = await db.query(
    `INSERT INTO posts (user_id, outfit_id, caption)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [userId, outfitId, caption]
  );
  return result.rows[0];
}

// Define other functions similarly
async function getAllPosts(userId = null) {
  const result = await db.query(`
    SELECT 
      p.*,
      u.username,
      u.avatar_url,
      o.image_url,
      o.name as outfit_name,
      o.description as outfit_description,
      o.total_price as outfit_total_price,
      o.style as outfit_style,
      o.color as outfit_color,
      o.brand as outfit_brand,
      o.season as outfit_season,
      o.occasion as outfit_occasion,
      o.created_at as outfit_created_at,
      COALESCE(like_counts.like_count, 0)::integer as like_count,
      COALESCE(comment_counts.comment_count, 0)::integer as comment_count,
      COALESCE(user_likes.is_liked, false) as is_liked
    FROM posts p
    JOIN users u ON p.user_id = u.id
    LEFT JOIN outfits o ON p.outfit_id = o.id
    LEFT JOIN (
      SELECT post_id, COUNT(*) as like_count
      FROM post_likes
      GROUP BY post_id
    ) like_counts ON p.id = like_counts.post_id
    LEFT JOIN (
      SELECT post_id, COUNT(*) as comment_count
      FROM post_comments
      GROUP BY post_id
    ) comment_counts ON p.id = comment_counts.post_id
    LEFT JOIN (
      SELECT post_id, true as is_liked
      FROM post_likes
      WHERE user_id = $1
    ) user_likes ON p.id = user_likes.post_id
    ORDER BY p.created_at DESC
  `, [userId]);
  return result.rows;
}

async function getPostById(id, userId = null) {
  const result = await db.query(
    `SELECT 
      p.*,
      u.username,
      u.avatar_url,
      o.image_url,
      o.name as outfit_name,
      o.description as outfit_description,
      o.total_price as outfit_total_price,
      o.style as outfit_style,
      o.color as outfit_color,
      o.brand as outfit_brand,
      o.season as outfit_season,
      o.occasion as outfit_occasion,
      o.created_at as outfit_created_at,
      COALESCE(like_counts.like_count, 0)::integer as like_count,
      COALESCE(comment_counts.comment_count, 0)::integer as comment_count,
      COALESCE(user_likes.is_liked, false) as is_liked
     FROM posts p
     JOIN users u ON p.user_id = u.id
     LEFT JOIN outfits o ON p.outfit_id = o.id
     LEFT JOIN (
       SELECT post_id, COUNT(*) as like_count
       FROM post_likes
       GROUP BY post_id
     ) like_counts ON p.id = like_counts.post_id
     LEFT JOIN (
       SELECT post_id, COUNT(*) as comment_count
       FROM post_comments
       GROUP BY post_id
     ) comment_counts ON p.id = comment_counts.post_id
     LEFT JOIN (
       SELECT post_id, true as is_liked
       FROM post_likes
       WHERE user_id = $2
     ) user_likes ON p.id = user_likes.post_id
     WHERE p.id = $1`,
    [id, userId]
  );
  if (result.rows.length === 0) return null;
  return result.rows[0];
};


async function updatePost(id, caption, image_url, description) {
  const result = await db.query(
    `UPDATE posts
     SET caption = $1,
         image_url = $2,
         description = $3
     WHERE id = $4
     RETURNING *`,
    [caption, image_url, description, id]
  );

  return result.rows[0];
}




async function deletePost(id) {
  const res = await db.query('DELETE FROM posts WHERE id = $1 RETURNING *', [id]);
  return res.rows.length > 0;
}

async function getPostsByUser(userId) {
  const result = await db.query(`
    SELECT 
      p.*,
      u.username,
      u.avatar_url,
      o.image_url,
      o.name as outfit_name,
      o.description as outfit_description,
      o.total_price as outfit_total_price,
      o.style as outfit_style,
      o.color as outfit_color,
      o.brand as outfit_brand,
      o.season as outfit_season,
      o.occasion as outfit_occasion,
      o.created_at as outfit_created_at,
      COALESCE(like_counts.like_count, 0)::integer as like_count,
      COALESCE(comment_counts.comment_count, 0)::integer as comment_count,
      COALESCE(user_likes.is_liked, false) as is_liked
    FROM posts p
    JOIN users u ON p.user_id = u.id
    LEFT JOIN outfits o ON p.outfit_id = o.id
    LEFT JOIN (
      SELECT post_id, COUNT(*) as like_count
      FROM post_likes
      GROUP BY post_id
    ) like_counts ON p.id = like_counts.post_id
    LEFT JOIN (
      SELECT post_id, COUNT(*) as comment_count
      FROM post_comments
      GROUP BY post_id
    ) comment_counts ON p.id = comment_counts.post_id
    LEFT JOIN (
      SELECT post_id, true as is_liked
      FROM post_likes
      WHERE user_id = $1
    ) user_likes ON p.id = user_likes.post_id
    WHERE p.user_id = $1
    ORDER BY p.created_at DESC
  `, [userId]);
  return result.rows;
}

// Export all functions
module.exports = { createPost, getAllPosts, getPostById, updatePost, deletePost, getPostsByUser };

