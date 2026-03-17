const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');
const User = require('../models/user');

function serializeUser(user) {
  return {
    id: user._id,
    google_id: user.googleId,
    name: user.name,
    email: user.email,
    profile_picture: user.profilePicture,
    created_at: user.createdAt.toISOString(),
  };
}

router.post('/', verifyToken, async (req, res) => {
  const { uid, email, name, picture } = req.user;

  if (!uid || !email) {
    console.error('Missing user data in token:', { uid, email });
    return res.status(400).json({ error: 'Invalid user data in token' });
  }

  try {
    const user = await User.findOneAndUpdate(
      { _id: uid },
      {
        $set: {
          googleId: uid,
          name: name || 'User',
          email,
          profilePicture: picture || null,
        },
      },
      {
        new: true,
        upsert: true,
        setDefaultsOnInsert: true,
      }
    );

    res.status(200).json({ success: true, user: serializeUser(user) });
  } catch (err) {
    console.error('User upsert error:', err);
    res.status(500).json({ error: `Failed to save user: ${err.message}` });
  }
});

router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.uid);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ success: true, user: serializeUser(user) });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
