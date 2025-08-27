const request = require('supertest');
const app = require('../app'); // Your Express app
const db = require('../db');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

describe('Comments API', () => {
  const testUser = {
    id: uuidv4(),
    email: 'test@example.com',
    username: 'testuser',
    password_hash: 'fakehash',
    avatar_url: 'http://avatar.jpg',
  };

  // Generate JWT token for test user
  const token = jwt.sign(
    { userId: testUser.id, email: testUser.email }, 
    process.env.JWT_SECRET || 'secret', 
    { expiresIn: '1h' }
  );

  const testPostId = uuidv4();

  beforeAll(async () => {
    // Insert test user
    await db.query(
      `INSERT INTO users (id, email, username, password_hash, avatar_url, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())`,
      [testUser.id, testUser.email, testUser.username, testUser.password_hash, testUser.avatar_url]
    );

    // Insert test post
    await db.query(
      `INSERT INTO posts (id, user_id, outfit_id, description, image_url, created_at, caption)
       VALUES ($1, $2, NULL, 'Post description', 'http://image.jpg', NOW(), 'Test Caption')`,
      [testPostId, testUser.id]
    );
  });

  afterAll(async () => {
    await db.query(`DELETE FROM post_comments WHERE post_id = $1`, [testPostId]);
    await db.query(`DELETE FROM posts WHERE id = $1`, [testPostId]);
    await db.query(`DELETE FROM users WHERE id = $1`, [testUser.id]);
    await db.end();
  });

  it('POST /comments - create a comment', async () => {
    const response = await request(app)
      .post('/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({
        post_id: testPostId,
        comment: 'This is a test comment' // remove user_id here
    });

    expect(response.statusCode).toBe(201);
    // Expect the response to be the inserted comment object, not a message string
    expect(response.body).toHaveProperty('id');
    expect(response.body).toHaveProperty('post_id', testPostId);
    expect(response.body).toHaveProperty('user_id', testUser.id);
    expect(response.body).toHaveProperty('comment', 'This is a test comment');
  });

  it('GET /comments/:postId - get comments for a post', async () => {
    const response = await request(app).get(`/comments/${testPostId}`);
    expect(response.statusCode).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body[0]).toHaveProperty('comment');
  });
});
