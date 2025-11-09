const { Pool } = require('pg');
require('dotenv').config();

const databaseUrl = process.env.DATABASE_URL || process.env.INTERNAL_DATABASE_URL;

if (!databaseUrl) {
  console.warn('⚠️ DATABASE_URL is not defined. Database connections will fail.');
}

let sslOption = false;
let hostname = 'unknown';

try {
  hostname = databaseUrl ? new URL(databaseUrl).hostname : 'unknown';
} catch {
  hostname = 'unknown';
}

if (hostname.includes('supabase.co')) {
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  sslOption = { rejectUnauthorized: false };
}

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: sslOption,
  connectionTimeoutMillis: 30000,
  idleTimeoutMillis: 60000,
  max: 5,
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000
});

console.log('🔌 Initializing database pool...');
let port = 'default';
try {
  port = databaseUrl ? new URL(databaseUrl).port || 'default' : 'unknown';
} catch {
  port = 'unknown';
}

console.log('📊 Connection string details:', {
  host: hostname,
  port,
  sslEnabled: !!sslOption
});

// Test connection on startup (non-blocking)
setTimeout(() => {
  pool.query('SELECT NOW()', (err, res) => {
    if (err) {
      console.error('❌ Database connection test failed:', err.message);
      console.error('Error code:', err.code);
      console.error('Error details:', {
        message: err.message,
        code: err.code,
        name: err.name,
        stack: err.stack
      });
      // Check connection string format
      if (databaseUrl) {
        try {
          const url = new URL(databaseUrl);
          console.error('Connection string details:', {
            host: url.hostname,
            port: url.port,
            user: url.username,
            database: url.pathname,
            hasPassword: !!url.password
          });
        } catch (e) {
          console.error('Could not parse connection string');
        }
      }
    } else {
      console.log('✅ Database connection test successful');
      console.log('Database time:', res.rows[0].now);
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
