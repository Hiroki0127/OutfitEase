const pool = require('../db');
const { getFollowStatsForUser } = require('./followController');

const parseCount = (value) => parseInt(value?.count ?? 0, 10);

exports.getPublicProfile = async (req, res) => {
  const { id: userId } = req.params;
  const viewerId = req.user?.userId ?? null;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const userResult = await pool.query(
      `SELECT id, email, username, avatar_url, created_at, role
       FROM users
       WHERE id = $1`,
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];

    const [postCountRes, outfitCountRes, stats, followStatusRes] = await Promise.all([
      pool.query(
        'SELECT COUNT(*)::int AS count FROM posts WHERE user_id = $1',
        [userId]
      ),
      pool.query(
        'SELECT COUNT(*)::int AS count FROM outfits WHERE user_id = $1',
        [userId]
      ),
      getFollowStatsForUser(userId),
      viewerId && viewerId !== userId
        ? pool.query(
            `SELECT 1 FROM user_followers
             WHERE follower_id = $1 AND following_id = $2
             LIMIT 1`,
            [viewerId, userId]
          )
        : Promise.resolve({ rows: [] }),
    ]);

    const isFollowing = followStatusRes.rows.length > 0;
    const isSelf = viewerId === userId;

    res.json({
      user,
      stats: {
        followerCount: stats.followerCount,
        followingCount: stats.followingCount,
        postCount: parseCount(postCountRes.rows[0]),
        outfitCount: parseCount(outfitCountRes.rows[0]),
      },
      isFollowing,
      isSelf,
    });
  } catch (error) {
    console.error('❌ Failed to fetch public profile:', error);
    res.status(500).json({ error: 'Failed to fetch public profile' });
  }
};

