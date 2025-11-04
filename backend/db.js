const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  connectionTimeoutMillis: 10000, // 10 seconds to connect
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  max: 20, // Maximum number of clients in the pool
});

// Handle pool errors
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

module.exports = pool;
