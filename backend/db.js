const { Pool } = require('pg');
require('dotenv').config();

// Render database connection configuration
const poolConfig = {
  connectionString: process.env.DATABASE_URL,
  // Increased timeouts for Render free tier
  connectionTimeoutMillis: 30000, // 30 seconds to connect (Render can be slow)
  idleTimeoutMillis: 60000, // Close idle clients after 60 seconds
  max: 10, // Maximum number of clients in the pool (lower for free tier)
  // Add SSL requirement for Render
  ssl: process.env.DATABASE_URL?.includes('render.com') ? { rejectUnauthorized: false } : false
};

console.log('🔌 Initializing database pool...');
console.log('📊 Pool config:', {
  hasConnectionString: !!process.env.DATABASE_URL,
  connectionTimeout: poolConfig.connectionTimeoutMillis,
  maxClients: poolConfig.max,
  sslEnabled: !!poolConfig.ssl
});

const pool = new Pool(poolConfig);

// Test connection on startup
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection test failed:', err.message);
  } else {
    console.log('✅ Database connection test successful');
  }
});

// Handle pool errors
pool.on('error', (err, client) => {
  console.error('❌ Unexpected error on idle client:', err.message);
  console.error('Error code:', err.code);
  // Don't exit on error - let the app continue and retry
});

module.exports = pool;
