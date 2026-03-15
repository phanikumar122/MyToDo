const admin = require('firebase-admin');
require('dotenv').config();

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './config/firebase-service-account.json';

if (!admin.apps.length) {
  try {
    const serviceAccount = require(require('path').resolve(serviceAccountPath));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('✅ Firebase Admin initialized');
  } catch (err) {
    console.error('❌ Firebase Admin init failed. Ensure firebase-service-account.json exists in backend/config/.', err.message);
    process.exit(1);
  }
}

module.exports = admin;
