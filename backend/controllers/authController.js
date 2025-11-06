const pool = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const registerUser = async (req, res) => {
  const { email, username, password, role = 'user' } = req.body;

  console.log('📝 Register request received');
  console.log('📧 Email:', email);
  console.log('👤 Username:', username);

  // Validate required fields
  if (!email || !username || !password) {
    return res.status(400).json({ message: 'Email, username, and password are required' });
  }

  try {
    // Check database connection first
    if (!pool) {
      console.error('❌ Database pool is not initialized!');
      return res.status(500).json({ 
        message: 'Database connection error',
        error: 'Database pool not initialized'
      });
    }

    // Check if user exists
    console.log('🔍 Checking if user exists...');
    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      console.log('❌ User already exists');
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash password
    console.log('🔐 Hashing password...');
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    console.log('➕ Inserting new user...');
    const newUser = await pool.query(
      'INSERT INTO users (email, username, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, email, username, created_at, role',
      [email, username, hashedPassword, role]
    );

    // Create JWT token
    if (!process.env.JWT_SECRET) {
      console.error('❌ JWT_SECRET is not set!');
      return res.status(500).json({ message: 'Server configuration error' });
    }

    const token = jwt.sign(
      { userId: newUser.rows[0].id, email: newUser.rows[0].email, role: newUser.rows[0].role || 'user' },
      process.env.JWT_SECRET,
      { expiresIn: '60d' }
    );

    console.log('✅ Registration successful');
    res.status(201).json({ 
      token,
      user: { 
        id: newUser.rows[0].id, 
        email: newUser.rows[0].email, 
        username: newUser.rows[0].username,
        avatar_url: null,
        created_at: newUser.rows[0].created_at,
        role: newUser.rows[0].role || 'user'
      },
      message: 'Registration successful'
    });
  } catch (error) {
    console.error('❌ Register Error:', error);
    console.error('Error details:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
      code: error.code
    });
    
    // Return more detailed error for debugging
    const errorMessage = error.message || 'Unknown error';
    const errorCode = error.code || 'NO_CODE';
    
    res.status(500).json({ 
      message: 'Database error',
      error: errorMessage,
      code: errorCode,
      type: error.name || 'Error'
    });
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
    // Check database connection first
    if (!pool) {
      console.error('❌ Database pool is not initialized!');
      return res.status(500).json({ 
        message: 'Database connection error',
        error: 'Database pool not initialized'
      });
    }
    
    // Find user by email
    console.log('🔍 Looking for user with email:', email);
    const startTime = Date.now();
    
    let userResult;
    let retries = 3;
    let dbError = null;
    
    while (retries > 0) {
      try {
        console.log(`🔍 Attempting database query (${4 - retries}/3)...`);
        userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        dbError = null;
        break; // Success!
      } catch (error) {
        dbError = error;
        retries--;
        console.error(`❌ Database query attempt failed:`, error.message);
        console.error('Error code:', error.code);
        
        if (retries > 0) {
          const waitTime = (4 - retries) * 2000; // 2s, 4s, 6s
          console.log(`⏳ Retrying in ${waitTime/1000} seconds...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
        }
      }
    }
    
    if (dbError) {
      console.error('❌ All database query attempts failed');
      console.error('Final error:', {
        message: dbError.message,
        code: dbError.code,
        name: dbError.name
      });
      return res.status(500).json({ 
        message: 'Database error',
        error: dbError.message,
        code: dbError.code || 'DB_ERROR'
      });
    }
    
    console.log(`🔍 Query took ${Date.now() - startTime}ms`);
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
    if (!process.env.JWT_SECRET) {
      console.error('❌ JWT_SECRET is not set!');
      return res.status(500).json({ message: 'Server configuration error' });
    }
    
    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role || 'user'},
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
    console.error('Error details:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
      code: error.code
    });
    
    // Return more detailed error for debugging (safe for production)
    const errorMessage = error.message || 'Unknown error';
    const errorCode = error.code || 'NO_CODE';
    
    res.status(500).json({ 
      message: 'Server error',
      error: errorMessage,
      code: errorCode,
      type: error.name || 'Error'
    });
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
