const admin = require('firebase-admin');

if (!admin.apps.length) {
  try {
    let serviceAccount;

    // Check if the environment variable exists
    if (process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      const jsonStr = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
      serviceAccount = JSON.parse(jsonStr);
      console.log('ℹ️ Using Firebase credentials from environment variable');
    } else {
      // Fall back to local file
      serviceAccount = require('./firebase-service-account.json');
      console.log('ℹ️ Using Firebase credentials from local file');
    }

    // Initialize Firebase Admin
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('✅ Firebase Admin initialized');
  } catch (err) {
    console.error('❌ Firebase Admin init failed:', err.message);
    process.exit(1);
  }
}

module.exports = admin;
