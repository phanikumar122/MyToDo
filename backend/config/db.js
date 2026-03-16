const mysql2 = require('mysql2/promise');

const poolConfig = process.env.DATABASE_URL
  ? { uri: process.env.DATABASE_URL }
  : {
      host:     process.env.DB_HOST     || 'localhost',
      port:     parseInt(process.env.DB_PORT || '3306'),
      user:     process.env.DB_USER     || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME     || 'todo_app',
    };

const pool = mysql2.createPool({
  ...poolConfig,
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
  ssl: process.env.DB_SSL === 'true' || process.env.DATABASE_URL ? {
    rejectUnauthorized: false
  } : undefined
});

// Validate connection on startup
(async () => {
  try {
    const conn = await pool.getConnection();
    
    // Get current database name to diagnose if it's 'test'
    const [[{ dbName }]] = await conn.query('SELECT DATABASE() as dbName');
    
    console.log(`✅ MySQL connected successfully to database: ${dbName}`);
    
    conn.release();
  } catch (err) {
    console.error('❌ MySQL connection failed:', err.message);
    // On Render, we might not want to exit immediately if DB is temporarily down,
    // but for initial startup validation, it's safer.
    if (process.env.NODE_ENV !== 'production') {
      process.exit(1);
    }
  }
})();

module.exports = pool;
