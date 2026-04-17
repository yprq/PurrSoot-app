const { Pool } = require('pg');

const pool = new Pool({
  user: 'yapdilse',
  // Eğer ortam değişkeni varsa onu kullan (Docker için), yoksa localhost kullan
  host: process.env.DB_HOST || 'localhost',
  database: 'pursoot_db',
  password: '12345',
  port: 5432,
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};
