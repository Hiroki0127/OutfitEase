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
  
  // For each post, get the clothing items if it has an outfit
  const postsWithItems = await Promise.all(
    result.rows.map(async (post) => {
      if (post.outfit_id) {
        const itemsRes = await db.query(
          `SELECT c.* FROM outfit_items oi
           JOIN clothing_items c ON c.id = oi.clothing_item_id
           WHERE oi.outfit_id = $1`,
          [post.outfit_id]
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
        
        return { ...post, outfit_items: formattedItems };
      }
      return post;
    })
  );
  
  return postsWithItems;
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
  
  const post = result.rows[0];
  
  // Get clothing items if the post has an outfit
  if (post.outfit_id) {
    const itemsRes = await db.query(
      `SELECT c.* FROM outfit_items oi
       JOIN clothing_items c ON c.id = oi.clothing_item_id
       WHERE oi.outfit_id = $1`,
      [post.outfit_id]
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
    
    return { ...post, outfit_items: formattedItems };
  }
  
  return post;
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




async function deletePost(id, userId = null) {
  let query = 'DELETE FROM posts WHERE id = $1';
  const params = [id];

  if (userId) {
    query += ' AND user_id = $2';
    params.push(userId);
  }

  query += ' RETURNING *';

  const res = await db.query(query, params);
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

