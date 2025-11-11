const postModel = require('../models/postModel');
const pool = require('../db'); // adjust the path if needed

const transformPost = (post) => {
  if (!post) return post;

  const transformedPost = { ...post };

  if (post.outfit_id) {
    transformedPost.outfit = {
      id: post.outfit_id,
      user_id: post.user_id,
      name: post.outfit_name,
      description: post.outfit_description,
      total_price: post.outfit_total_price,
      style: post.outfit_style,
      color: post.outfit_color,
      brand: post.outfit_brand,
      season: post.outfit_season,
      occasion: post.outfit_occasion,
      image_url: post.image_url,
      created_at: post.outfit_created_at,
      items: post.outfit_items || [],
    };
  } else {
    transformedPost.outfit = null;
  }

  delete transformedPost.outfit_name;
  delete transformedPost.outfit_description;
  delete transformedPost.outfit_total_price;
  delete transformedPost.outfit_style;
  delete transformedPost.outfit_color;
  delete transformedPost.outfit_brand;
  delete transformedPost.outfit_season;
  delete transformedPost.outfit_occasion;
  delete transformedPost.outfit_created_at;
  delete transformedPost.outfit_items;

  return transformedPost;
};

const transformPosts = (posts = []) => posts.map(transformPost);

exports.createPost = async (req, res) => {
  const { outfitId, caption } = req.body;
  const userId = req.user.userId;  // or req.user.id, whichever you use consistently

  if (!outfitId) {
    return res.status(400).json({ error: 'Outfit ID is required' });
  }

  try {
    const newPost = await postModel.createPost(userId, outfitId, caption);
    
    // Get the full post with outfit details
    const fullPost = await postModel.getPostById(newPost.id, userId);
    
    // Transform post to include structured outfit data
    res.status(201).json(transformPost(fullPost));
  } catch (err) {
    console.error('Failed to create post:', err);
    res.status(500).json({ error: 'Failed to create post' });
  }
};


exports.getAllPosts = async (req, res) => {
  try {
    console.log('📋 Getting all posts...');
    console.log('👤 User ID:', req.user?.userId);
    const posts = await postModel.getAllPosts(req.user?.userId);
    console.log(`✅ Found ${posts.length} posts`);
    
    res.json(transformPosts(posts));
  } catch (err) {
    console.error('Error fetching posts:', err);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
};

exports.getPostsByUser = async (req, res) => {
  try {
    const userId = req.user.userId;
    const posts = await postModel.getPostsByUser(userId, req.user.userId);
    
    res.json(transformPosts(posts));
  } catch (err) {
    console.error('Error fetching user posts:', err);
    res.status(500).json({ error: 'Failed to fetch user posts' });
  }
};

exports.getPostsByUserId = async (req, res) => {
  try {
    const { id: targetUserId } = req.params;
    const viewerId = req.user?.userId ?? null;

    const posts = await postModel.getPostsByUser(targetUserId, viewerId);

    res.json(transformPosts(posts));
  } catch (err) {
    console.error('Error fetching posts by user ID:', err);
    res.status(500).json({ error: 'Failed to fetch posts for user' });
  }
};


exports.getPostById = async (req, res) => {
  const { id } = req.params;
  try {
    const post = await postModel.getPostById(id, req.user?.userId);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    
    // Transform post to include structured outfit data
    res.json(transformPost(post));
  } catch (err) {
    console.error('Error fetching post:', err);
    res.status(500).json({ error: 'Failed to fetch post' });
  }
};

exports.updatePost = async (req, res) => {
  const { id } = req.params;
  const { caption, image_url, description } = req.body;

  try {
    const updatedPost = await postModel.updatePost(id, caption, image_url, description );
    if (!updatedPost) return res.status(404).json({ error: 'Post not found' });
    res.json(updatedPost);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update post' });
  }
};



exports.deletePost = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.userId;
  const userRole = req.user.role;
  const isAdmin = userRole === 'admin' || userRole === 'moderator';

  try {
    const deleted = await postModel.deletePost(id, isAdmin ? null : userId);
    if (!deleted) {
      if (isAdmin) {
        return res.status(404).json({ error: 'Post not found' });
      }
      return res.status(403).json({ error: 'You are not authorized to delete this post' });
    }

    res.json({ message: 'Post deleted' });
  } catch (err) {
    console.error('Error deleting post:', err);
    res.status(500).json({ error: 'Failed to delete post' });
  }
};
