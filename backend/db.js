const { Pool } = require('pg');
require('dotenv').config();

// Render database connection configuration
const isRender = process.env.DATABASE_URL?.includes('render.com') || 
                 process.env.DATABASE_URL?.includes('onrender.com') ||
                 process.env.RENDER;

// Use internal database URL if available (better for Render)
const databaseUrl = process.env.DATABASE_URL || process.env.INTERNAL_DATABASE_URL;

const poolConfig = {
  connectionString: databaseUrl,
  // Increased timeouts for Render free tier
  connectionTimeoutMillis: 90000, // 90 seconds to connect (Render free tier can be very slow)
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  max: 3, // Very low for free tier to avoid connection limits
  // Render PostgreSQL requires SSL
  ssl: isRender ? {
    require: true,
    rejectUnauthorized: false // Render uses self-signed certificates
  } : false,
  // Allow connection to be kept alive
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000
};

console.log('🔌 Initializing database pool...');
console.log('📊 Pool config:', {
  hasConnectionString: !!process.env.DATABASE_URL,
  connectionTimeout: poolConfig.connectionTimeoutMillis,
  maxClients: poolConfig.max,
  sslEnabled: !!poolConfig.ssl
});

const pool = new Pool(poolConfig);

// Test connection on startup (non-blocking)
setTimeout(() => {
  pool.query('SELECT NOW()', (err, res) => {
    if (err) {
      console.error('❌ Database connection test failed:', err.message);
      console.error('Error code:', err.code);
    } else {
      console.log('✅ Database connection test successful');
    }
  });
}, 2000); // Wait 2 seconds for app to fully start

// Handle pool errors
pool.on('error', (err, client) => {
  console.error('❌ Unexpected error on idle client:', err.message);
  console.error('Error code:', err.code);
  // Don't exit on error - let the app continue and retry
});

module.exports = pool;
