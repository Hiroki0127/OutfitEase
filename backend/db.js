const { Pool } = require('pg');
const dns = require('dns');
const { promisify } = require('util');
require('dotenv').config();

// Force IPv4 DNS resolution to avoid IPv6 issues
dns.setDefaultResultOrder('ipv4first');
const dnsLookup = promisify(dns.lookup);

// Database connection configuration
const isRender = process.env.DATABASE_URL?.includes('render.com') || 
                 process.env.DATABASE_URL?.includes('onrender.com') ||
                 process.env.RENDER;

const isSupabase = process.env.DATABASE_URL?.includes('supabase.co');

// Use internal database URL if available (better for Render)
const databaseUrl = process.env.DATABASE_URL || process.env.INTERNAL_DATABASE_URL;

// Base pool configuration
const poolConfig = {
  // Increased timeouts for free tier databases
  connectionTimeoutMillis: 30000, // 30 seconds to connect
  idleTimeoutMillis: 60000, // Close idle clients after 60 seconds (increased)
  max: 5, // Connection pool size
  // SSL configuration
  ssl: isSupabase || isRender ? {
    require: true,
    rejectUnauthorized: false // Supabase and Render use self-signed certificates
  } : false,
  // Allow connection to be kept alive
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000
};

if (databaseUrl) {
  try {
    const url = new URL(databaseUrl);
    const decodedUser = decodeURIComponent(url.username ?? '');
    const decodedPassword = decodeURIComponent(url.password ?? '');
    const databaseName = url.pathname ? url.pathname.replace(/^\//, '') : undefined;

    // Populate poolConfig with explicit properties so we can force IPv4 where needed
    Object.assign(poolConfig, {
      user: decodedUser || undefined,
      password: decodedPassword || undefined,
      database: databaseName || undefined,
      port: parseInt(url.port, 10) || 5432,
      host: url.hostname || undefined
    });

    if (isSupabase) {
      poolConfig.family = 4; // Force IPv4 connections
      console.log('🌐 Supabase detected - forcing IPv4 for database connections');

      // Attempt to resolve the hostname to IPv4 ahead of time for reliability
      dnsLookup(url.hostname, { family: 4 }, (err, address) => {
        if (err) {
          console.warn(`⚠️  Could not resolve ${url.hostname} to IPv4:`, err.message);
        } else {
          console.log(`🌐 Resolved ${url.hostname} to IPv4: ${address}`);
          poolConfig.host = address;
        }
      });
    } else {
      // For non-Supabase connection strings fall back to using the original URL
      poolConfig.connectionString = databaseUrl;
    }
  } catch (error) {
    console.error('❌ Failed to parse DATABASE_URL:', error.message);
    poolConfig.connectionString = databaseUrl;
  }
} else {
  console.warn('⚠️ DATABASE_URL is not defined');
}

console.log('🔌 Initializing database pool...');
if (databaseUrl) {
  try {
    const url = new URL(databaseUrl);
    console.log('📊 Connection string details:', {
      host: url.hostname,
      port: url.port || 'default',
      user: url.username,
      database: url.pathname,
      hasPassword: !!url.password,
      isPooler: url.hostname.includes('pooler'),
      isSessionPooler: url.port === '6543'
    });
  } catch (e) {
    console.warn('⚠️  Could not parse connection string');
  }
}
console.log('📊 Pool config:', {
  hasConnectionString: !!process.env.DATABASE_URL,
  connectionTimeout: poolConfig.connectionTimeoutMillis,
  maxClients: poolConfig.max,
  sslEnabled: !!poolConfig.ssl,
  isSupabase: isSupabase,
  isRender: isRender,
  databaseHost: databaseUrl ? (() => {
    try {
      return new URL(databaseUrl).hostname;
    } catch {
      return 'unknown';
    }
  })() : 'none'
});

const pool = new Pool(poolConfig);

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
