require('dotenv').config();
const express = require('express');
const cors    = require('cors');

// Initialize Firebase Admin (must happen before route imports that use it)
require('./config/firebase');

const userRoutes = require('./routes/users');
const taskRoutes = require('./routes/tasks');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ──────────────────────────────────────────────
const allowedOrigins = [
  'http://localhost:3000',
  'http://10.0.2.2:3000',
  process.env.FRONTEND_URL, // e.g. https://todo-app-xxxx.web.app
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV !== 'production') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));
app.use(express.json({ limit: '10mb' }));

// ── Routes ──────────────────────────────────────────────────
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);

// Health check
app.get('/health', (_req, res) =>
  res.json({ status: 'OK', timestamp: new Date().toISOString() }));

// 404 handler
app.use((_req, res) => res.status(404).json({ error: 'Route not found' }));

// Global error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () =>
  console.log(`🚀 To-Do API running on http://localhost:${PORT}`));
