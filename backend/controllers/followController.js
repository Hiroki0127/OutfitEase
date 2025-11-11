const pool = require('../db');

const parseCount = (value) => parseInt(value?.count ?? 0, 10);

async function getFollowStatsForUser(userId) {
  const [followersRes, followingRes] = await Promise.all([
    pool.query(
      'SELECT COUNT(*)::int AS count FROM user_followers WHERE following_id = $1',
      [userId]
    ),
    pool.query(
      'SELECT COUNT(*)::int AS count FROM user_followers WHERE follower_id = $1',
      [userId]
    ),
  ]);

  return {
    followerCount: parseCount(followersRes.rows[0]),
    followingCount: parseCount(followingRes.rows[0]),
  };
}

exports.followUser = async (req, res) => {
  const followerId = req.user.userId;
  const { id: followingId } = req.params;

  if (!followingId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  if (followerId === followingId) {
    return res.status(400).json({ error: 'You cannot follow yourself' });
  }

  try {
    await pool.query(
      `INSERT INTO user_followers (follower_id, following_id)
       VALUES ($1, $2)
       ON CONFLICT (follower_id, following_id) DO NOTHING`,
      [followerId, followingId]
    );

    const stats = await getFollowStatsForUser(followingId);

    res.json({
      message: 'User followed successfully',
      isFollowing: true,
      stats,
    });
  } catch (error) {
    console.error('❌ Failed to follow user:', error);
    res.status(500).json({ error: 'Failed to follow user' });
  }
};

exports.unfollowUser = async (req, res) => {
  const followerId = req.user.userId;
  const { id: followingId } = req.params;

  if (!followingId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  if (followerId === followingId) {
    return res.status(400).json({ error: 'You cannot unfollow yourself' });
  }

  try {
    await pool.query(
      `DELETE FROM user_followers
       WHERE follower_id = $1 AND following_id = $2`,
      [followerId, followingId]
    );

    const stats = await getFollowStatsForUser(followingId);

    res.json({
      message: 'User unfollowed successfully',
      isFollowing: false,
      stats,
    });
  } catch (error) {
    console.error('❌ Failed to unfollow user:', error);
    res.status(500).json({ error: 'Failed to unfollow user' });
  }
};

exports.getFollowStatus = async (req, res) => {
  const followerId = req.user.userId;
  const { id: followingId } = req.params;

  if (!followingId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  if (followerId === followingId) {
    return res.json({ isFollowing: false });
  }

  try {
    const result = await pool.query(
      `SELECT 1 FROM user_followers
       WHERE follower_id = $1 AND following_id = $2
       LIMIT 1`,
      [followerId, followingId]
    );

    res.json({ isFollowing: result.rows.length > 0 });
  } catch (error) {
    console.error('❌ Failed to get follow status:', error);
    res.status(500).json({ error: 'Failed to get follow status' });
  }
};

exports.getFollowStats = async (req, res) => {
  const { id: userId } = req.params;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const stats = await getFollowStatsForUser(userId);
    res.json(stats);
  } catch (error) {
    console.error('❌ Failed to get follow stats:', error);
    res.status(500).json({ error: 'Failed to get follow stats' });
  }
};

exports.getFollowers = async (req, res) => {
  const { id: userId } = req.params;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const result = await pool.query(
      `SELECT 
         u.id,
         u.username,
         u.avatar_url,
         uf.created_at
       FROM user_followers uf
       JOIN users u ON uf.follower_id = u.id
       WHERE uf.following_id = $1
       ORDER BY uf.created_at DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('❌ Failed to get followers:', error);
    res.status(500).json({ error: 'Failed to get followers' });
  }
};

exports.getFollowing = async (req, res) => {
  const { id: userId } = req.params;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const result = await pool.query(
      `SELECT 
         u.id,
         u.username,
         u.avatar_url,
         uf.created_at
       FROM user_followers uf
       JOIN users u ON uf.following_id = u.id
       WHERE uf.follower_id = $1
       ORDER BY uf.created_at DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('❌ Failed to get following list:', error);
    res.status(500).json({ error: 'Failed to get following list' });
  }
};

exports.getFollowStatsForUser = getFollowStatsForUser;

