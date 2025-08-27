const commentsModel = require('../models/commentsModel');

exports.addComment = async (req, res) => {
  const { postId, comment } = req.body;
  const userId = req.user.userId; // from token
  console.log('userId from token:', userId);

  try {
    const newComment = await commentsModel.addComment(postId, userId, comment);
    res.status(201).json(newComment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add comment' });
  }
};

exports.getComments = async (req, res) => {
  const { postId } = req.params;

  try {
    const comments = await commentsModel.getCommentsByPostId(postId);
    res.json(comments);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
};


exports.deleteComment = async (req, res) => {
  const commentId = req.params.id;
  const userId = req.user.userId;       // from authenticateToken middleware
  const userRole = req.user.role;   // from authenticateToken middleware

  try {
    // First check if the comment exists
    const result = await db.query(
      `SELECT * FROM post_comments WHERE id = $1`,
      [commentId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    const comment = result.rows[0];

    // Only the user who posted the comment or an admin/moderator can delete
    if (comment.user_id !== userId && userRole !== 'admin' && userRole !== 'moderator') {
      return res.status(403).json({ error: 'Forbidden: You do not have permission to delete this comment.' });
    }

    // Delete the comment
    await db.query(`DELETE FROM post_comments WHERE id = $1`, [commentId]);

    res.json({ message: 'Comment deleted successfully' });
  } catch (err) {
    console.error('Error deleting comment:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getReplies = async (req, res) => {
  const { commentId } = req.params;

  try {
    const replies = await commentsModel.getRepliesByCommentId(commentId);
    res.json(replies);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch replies' });
  }
};

exports.addReply = async (req, res) => {
  const { parentCommentId } = req.params;
  const { comment } = req.body;
  const userId = req.user.userId;

  try {
    const newReply = await commentsModel.addReply(parentCommentId, userId, comment);
    res.status(201).json(newReply);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add reply' });
  }
};
