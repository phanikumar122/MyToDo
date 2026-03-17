require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectToDatabase = require('./config/db');

console.log('--- Environment Check ---');
console.log(`Port: ${process.env.PORT || 3000}`);
console.log(`Node Env: ${process.env.NODE_ENV || 'development'}`);
console.log(`MongoDB URI: ${process.env.MONGODB_URI ? 'SET' : 'NOT SET'}`);
console.log(`MongoDB DB Name: ${process.env.MONGODB_DB_NAME || 'todo_app'}`);
console.log(
  `Firebase Config: ${
    process.env.FIREBASE_SERVICE_ACCOUNT
      ? 'SET (Env Var)'
      : process.env.FIREBASE_SERVICE_ACCOUNT_JSON
        ? 'SET (JSON Env Var)'
        : 'NOT SET (Fallback to file)'
  }`
);
console.log('-------------------------');

require('./config/firebase');

const userRoutes = require('./routes/users');
const taskRoutes = require('./routes/tasks');

const app = express();
const PORT = process.env.PORT || 3000;

const allowedOrigins = [
  'http://localhost:3000',
  'http://10.0.2.2:3000',
  process.env.FRONTEND_URL,
].filter(Boolean);

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      if (allowedOrigins.includes(origin) || process.env.NODE_ENV !== 'production') {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
  })
);

app.use(express.json({ limit: '10mb' }));

app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);

app.get('/health', (_req, res) =>
  res.json({ status: 'OK', timestamp: new Date().toISOString() }));

app.use((_req, res) => res.status(404).json({ error: 'Route not found' }));

app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

async function startServer() {
  try {
    await connectToDatabase();
    app.listen(PORT, () => {
      console.log(`To-Do API running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
}

startServer();
