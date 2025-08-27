const { v4: uuidv4 } = require('uuid');
const db = require('../db');

exports.addComment = async (postId, userId, comment) => {
  const result = await db.query(
    `INSERT INTO post_comments (post_id, user_id, comment)
     VALUES ($1, $2, $3) RETURNING *`,
    [postId, userId, comment]
  );
  return result.rows[0];
};

exports.getCommentsByPostId = async (postId) => {
  // Get main comments (not replies)
  const result = await db.query(
    `SELECT pc.*, u.username 
     FROM post_comments pc
     JOIN users u ON pc.user_id = u.id
     WHERE pc.post_id = $1 AND pc.parent_comment_id IS NULL
     ORDER BY pc.created_at ASC`,
    [postId]
  );
  
  // For each comment, get its replies recursively
  const commentsWithReplies = await Promise.all(
    result.rows.map(async (comment) => {
      const replies = await getRepliesRecursively(comment.id);
      return {
        ...comment,
        replies: replies
      };
    })
  );
  
  return commentsWithReplies;
};

// Recursive function to get all nested replies
async function getRepliesRecursively(parentCommentId) {
  const repliesResult = await db.query(
    `SELECT pc.*, u.username 
     FROM post_comments pc
     JOIN users u ON pc.user_id = u.id
     WHERE pc.parent_comment_id = $1 
     ORDER BY pc.created_at ASC`,
    [parentCommentId]
  );
  
  // For each reply, get its nested replies
  const repliesWithNestedReplies = await Promise.all(
    repliesResult.rows.map(async (reply) => {
      const nestedReplies = await getRepliesRecursively(reply.id);
      return {
        ...reply,
        replies: nestedReplies
      };
    })
  );
  
  return repliesWithNestedReplies;
}

exports.deleteComment = async (commentId) => {
  const result = await db.query(
    `DELETE FROM post_comments WHERE id = $1 RETURNING *`,
    [commentId]
  );
  return result.rows[0]; // null if not found
};

exports.addReply = async (parentCommentId, userId, comment) => {
  const result = await db.query(
    `INSERT INTO post_comments (post_id, user_id, comment, parent_comment_id)
     SELECT post_id, $2, $3, $1
     FROM post_comments 
     WHERE id = $1
     RETURNING *`,
    [parentCommentId, userId, comment]
  );
  return result.rows[0];
};

exports.getRepliesByCommentId = async (commentId) => {
  const result = await db.query(
    `SELECT pc.*, u.username 
     FROM post_comments pc
     JOIN users u ON pc.user_id = u.id
     WHERE pc.parent_comment_id = $1 
     ORDER BY pc.created_at ASC`,
    [commentId]
  );
  return result.rows;
};
