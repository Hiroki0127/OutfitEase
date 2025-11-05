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

// Parse connection string to extract host and force IPv4 resolution
let connectionConfig = {};
if (databaseUrl) {
  try {
    const url = new URL(databaseUrl);
    
    // For Supabase, try to resolve to IPv4 explicitly to avoid IPv6 issues
    // We'll use the hostname but ensure family: 4 is set
    connectionConfig = {
      host: url.hostname,
      port: parseInt(url.port) || 5432,
      database: url.pathname.slice(1) || 'postgres',
      user: url.username || 'postgres',
      password: url.password || '',
      // Force IPv4 to avoid IPv6 issues
      family: 4
    };
    
    // Try to resolve DNS to IPv4 in background (for logging)
    if (isSupabase) {
      dnsLookup(url.hostname, { family: 4 })
        .then(resolved => {
          console.log(`🌐 Resolved ${url.hostname} to IPv4: ${resolved.address}`);
        })
        .catch(() => {
          console.warn(`⚠️  Could not resolve ${url.hostname} to IPv4`);
        });
    }
  } catch (e) {
    // Fallback to connection string if parsing fails
    connectionConfig.connectionString = databaseUrl;
  }
}

const poolConfig = {
  ...connectionConfig,
  // Use connectionString if host-based config failed
  connectionString: connectionConfig.host ? undefined : databaseUrl,
  // Increased timeouts for free tier databases
  connectionTimeoutMillis: 30000, // 30 seconds to connect
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
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

console.log('🔌 Initializing database pool...');
console.log('📊 Pool config:', {
  hasConnectionString: !!process.env.DATABASE_URL,
  connectionTimeout: poolConfig.connectionTimeoutMillis,
  maxClients: poolConfig.max,
  sslEnabled: !!poolConfig.ssl,
  isSupabase: isSupabase,
  isRender: isRender,
  databaseHost: databaseUrl ? new URL(databaseUrl).hostname : 'none',
  usingIPv4: poolConfig.family === 4
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
