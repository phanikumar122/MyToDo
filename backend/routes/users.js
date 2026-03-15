const express = require('express');
const router  = express.Router();
const pool    = require('../config/db');
const verifyToken = require('../middleware/auth');

/**
 * POST /api/users
 * Upsert a user on Google Sign-In (called from Flutter after auth).
 */
router.post('/', verifyToken, async (req, res) => {
  const { uid, email, name, picture } = req.user;

  // google_id mirrors Firebase uid for Google-auth users
  const sql = `
    INSERT INTO users (id, google_id, name, email, profile_picture)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      name            = VALUES(name),
      email           = VALUES(email),
      profile_picture = VALUES(profile_picture);
  `;
  try {
    await pool.execute(sql, [uid, uid, name, email, picture]);
    const [[user]] = await pool.execute('SELECT * FROM users WHERE id = ?', [uid]);
    res.status(200).json({ success: true, user });
  } catch (err) {
    console.error('User upsert error:', err);
    res.status(500).json({ error: 'Failed to save user' });
  }
});

/**
 * GET /api/users/me
 * Return the authenticated user's profile.
 */
router.get('/me', verifyToken, async (req, res) => {
  try {
    const [[user]] = await pool.execute('SELECT * FROM users WHERE id = ?', [req.user.uid]);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ success: true, user });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
