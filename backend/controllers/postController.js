const postModel = require('../models/postModel');
const pool = require('../db'); // adjust the path if needed

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
    const transformedPost = { ...fullPost };
    
    // Create outfit object if outfit_id exists
    if (fullPost.outfit_id) {
      transformedPost.outfit = {
        id: fullPost.outfit_id,
        user_id: fullPost.user_id,
        name: fullPost.outfit_name,
        description: fullPost.outfit_description,
        total_price: fullPost.outfit_total_price,
        style: fullPost.outfit_style,
        color: fullPost.outfit_color,
        brand: fullPost.outfit_brand,
        season: fullPost.outfit_season,
        occasion: fullPost.outfit_occasion,
        image_url: fullPost.image_url,
        created_at: fullPost.outfit_created_at
      };
    } else {
      transformedPost.outfit = null;
    }
    
    // Remove individual outfit fields to avoid duplication
    delete transformedPost.outfit_name;
    delete transformedPost.outfit_description;
    delete transformedPost.outfit_total_price;
    delete transformedPost.outfit_style;
    delete transformedPost.outfit_color;
    delete transformedPost.outfit_brand;
    delete transformedPost.outfit_season;
    delete transformedPost.outfit_occasion;
    delete transformedPost.outfit_created_at;
    
    res.status(201).json(transformedPost);
  } catch (err) {
    console.error('Failed to create post:', err);
    res.status(500).json({ error: 'Failed to create post' });
  }
};


exports.getAllPosts = async (req, res) => {
  try {
    const posts = await postModel.getAllPosts(req.user?.userId);
    
    // Transform posts to include structured outfit data
    const transformedPosts = posts.map(post => {
      const transformedPost = { ...post };
      
      // Create outfit object if outfit_id exists
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
          created_at: post.outfit_created_at
        };
      } else {
        transformedPost.outfit = null;
      }
      
      // Remove individual outfit fields to avoid duplication
      delete transformedPost.outfit_name;
      delete transformedPost.outfit_description;
      delete transformedPost.outfit_total_price;
      delete transformedPost.outfit_style;
      delete transformedPost.outfit_color;
      delete transformedPost.outfit_brand;
      delete transformedPost.outfit_season;
      delete transformedPost.outfit_occasion;
      delete transformedPost.outfit_created_at;
      
      return transformedPost;
    });
    
    res.json(transformedPosts);
  } catch (err) {
    console.error('Error fetching posts:', err);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
};

exports.getPostsByUser = async (req, res) => {
  try {
    const userId = req.user.userId;
    const posts = await postModel.getPostsByUser(userId);
    
    // Transform posts to include structured outfit data
    const transformedPosts = posts.map(post => {
      const transformedPost = { ...post };
      
      // Create outfit object if outfit_id exists
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
          created_at: post.outfit_created_at
        };
      } else {
        transformedPost.outfit = null;
      }
      
      // Remove individual outfit fields to avoid duplication
      delete transformedPost.outfit_name;
      delete transformedPost.outfit_description;
      delete transformedPost.outfit_total_price;
      delete transformedPost.outfit_style;
      delete transformedPost.outfit_color;
      delete transformedPost.outfit_brand;
      delete transformedPost.outfit_season;
      delete transformedPost.outfit_occasion;
      delete transformedPost.outfit_created_at;
      
      return transformedPost;
    });
    
    res.json(transformedPosts);
  } catch (err) {
    console.error('Error fetching user posts:', err);
    res.status(500).json({ error: 'Failed to fetch user posts' });
  }
};


exports.getPostById = async (req, res) => {
  const { id } = req.params;
  try {
    const post = await postModel.getPostById(id, req.user?.userId);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    
    // Transform post to include structured outfit data
    const transformedPost = { ...post };
    
    // Create outfit object if outfit_id exists
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
        created_at: post.outfit_created_at
      };
    } else {
      transformedPost.outfit = null;
    }
    
    // Remove individual outfit fields to avoid duplication
    delete transformedPost.outfit_name;
    delete transformedPost.outfit_description;
    delete transformedPost.outfit_total_price;
    delete transformedPost.outfit_style;
    delete transformedPost.outfit_color;
    delete transformedPost.outfit_brand;
    delete transformedPost.outfit_season;
    delete transformedPost.outfit_occasion;
    delete transformedPost.outfit_created_at;
    
    res.json(transformedPost);
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

  try {
    const deleted = await postModel.deletePost(id);
    if (!deleted) return res.status(404).json({ error: 'Post not found' });
    res.json({ message: 'Post deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete post' });
  }
};
