const mongoose = require('mongoose');

let connectPromise = null;

async function connectToDatabase() {
  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  if (!connectPromise) {
    const mongoUri = process.env.MONGODB_URI;

    if (!mongoUri) {
      throw new Error('Missing MONGODB_URI environment variable');
    }

    const dbName = process.env.MONGODB_DB_NAME || 'todo_app';

    connectPromise = mongoose.connect(mongoUri, {
      dbName,
      serverSelectionTimeoutMS: 10000,
    });
  }

  try {
    console.log('⏳ Connecting to MongoDB...');
    await connectPromise;
    console.log(`✅ MongoDB connected successfully to database: ${mongoose.connection.name}`);
    return mongoose.connection;
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    connectPromise = null;
    throw err;
  }
}

module.exports = connectToDatabase;
