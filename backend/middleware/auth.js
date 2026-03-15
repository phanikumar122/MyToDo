const admin = require('../config/firebase');

/**
 * Middleware: verify Firebase ID token in Authorization header.
 * Sets req.user = { uid, email, name, picture }
 */
const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }

  const idToken = authHeader.split('Bearer ')[1];
  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = {
      uid:     decoded.uid,
      email:   decoded.email,
      name:    decoded.name    || decoded.email,
      picture: decoded.picture || null,
    };
    next();
  } catch (err) {
    console.error('Token verification error:', err.code);
    return res.status(401).json({ error: 'Unauthorized: Invalid or expired token' });
  }
};

module.exports = verifyToken;
