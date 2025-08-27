const pool = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const registerUser = async (req, res) => {
  const { email, username, password , role = 'user'} = req.body;

  try {
    // Check if user exists
    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const newUser = await pool.query(
      'INSERT INTO users (email, username, password_hash) VALUES ($1, $2, $3) RETURNING id, email, username',
      [email, username, hashedPassword]
    );

    res.status(201).json({ 
      token: jwt.sign(
        { userId: newUser.rows[0].id, email: newUser.rows[0].email, role: 'user' },
        process.env.JWT_SECRET,
        { expiresIn: '60d' }
      ),
      user: { 
        id: newUser.rows[0].id, 
        email: newUser.rows[0].email, 
        username: newUser.rows[0].username,
        avatar_url: null,
        created_at: new Date().toISOString(),
        role: 'user'
      },
      message: 'Registration successful'
    });
  } catch (error) {
    console.error('Register Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const loginUser = async (req, res) => {
  console.log('🔐 Login request received');
  console.log('📧 Headers:', req.headers);
  console.log('📦 Body:', req.body);
  console.log('🔗 URL:', req.url);
  console.log('📋 Method:', req.method);
  
  const { email, password } = req.body;

  // Validate required fields
  if (!email || !password) {
    console.log('❌ Missing email or password');
    console.log('📧 Email:', email);
    console.log('🔒 Password:', password ? '[PRESENT]' : '[MISSING]');
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    // Find user by email
    console.log('🔍 Looking for user with email:', email);
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    console.log('🔍 User found:', userResult.rows.length > 0);
    if (userResult.rows.length === 0) {
      console.log('❌ User not found');
      return res.status(400).json({ message: 'Invalid credentials' });
    }
    const user = userResult.rows[0];

    // Compare password
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Create JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email, role : user.role},
      process.env.JWT_SECRET,
      { expiresIn: '60d' }
    );
    
    res.json({ 
      token, 
      user: { 
        id: user.id, 
        email: user.email, 
        username: user.username,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
        role: user.role
      },
      message: 'Login successful'
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const updateProfile = async (req, res) => {
  const { username, avatar_url } = req.body;
  const userId = req.user.userId;

  try {
    // Update user profile
    const updateResult = await pool.query(
      'UPDATE users SET username = COALESCE($1, username), avatar_url = COALESCE($2, avatar_url) WHERE id = $3 RETURNING id, email, username, avatar_url, created_at, role',
      [username, avatar_url, userId]
    );

    if (updateResult.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const updatedUser = updateResult.rows[0];
    
    res.json({ 
      user: { 
        id: updatedUser.id, 
        email: updatedUser.email, 
        username: updatedUser.username,
        avatar_url: updatedUser.avatar_url,
        created_at: updatedUser.created_at,
        role: updatedUser.role
      },
      message: 'Profile updated successfully'
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { registerUser, loginUser, updateProfile };
