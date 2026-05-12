const { Pool } = require('pg');

// 🔴 تأكد من وجود الاتصال
if (!process.env.DATABASE_URL) {
  throw new Error('❌ DATABASE_URL is missing');
}

// 🟢 اتصال واحد فقط (Supabase)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL error:', err);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  getClient: () => pool.connect(),
  pool,
};
