const express = require('express');
const router  = express.Router();
const pool    = require('../config/db');
const verifyToken = require('../middleware/auth');

// All task routes require authentication
router.use(verifyToken);

/* ────────────────────────────────────────────────────────────
   GET /api/tasks
   Returns all tasks for the authenticated user.
   Optional query params: status, priority, category
──────────────────────────────────────────────────────────── */
router.get('/', async (req, res) => {
  const uid = req.user.uid;
  const { status, priority, category } = req.query;

  let sql    = 'SELECT * FROM tasks WHERE user_id = ?';
  const args = [uid];

  if (status)   { sql += ' AND status = ?';   args.push(status); }
  if (priority) { sql += ' AND priority = ?'; args.push(priority); }
  if (category) { sql += ' AND category = ?'; args.push(category); }

  sql += ' ORDER BY deadline ASC, created_at DESC';

  try {
    const [tasks] = await pool.execute(sql, args);
    res.json({ success: true, tasks });
  } catch (err) {
    console.error('Get tasks error:', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

/* ────────────────────────────────────────────────────────────
   GET /api/tasks/stats
   Returns productivity statistics for the authenticated user.
──────────────────────────────────────────────────────────── */
router.get('/stats', async (req, res) => {
  const uid = req.user.uid;
  try {
    // Today's completed
    const [[{ todayCompleted }]] = await pool.execute(`
      SELECT COUNT(*) AS todayCompleted FROM tasks
      WHERE user_id = ? AND status = 'completed'
        AND DATE(updated_at) = CURDATE()
    `, [uid]);

    // Total tasks
    const [[{ total }]] = await pool.execute(
      'SELECT COUNT(*) AS total FROM tasks WHERE user_id = ?', [uid]);

    // Completed total
    const [[{ completed }]] = await pool.execute(
      "SELECT COUNT(*) AS completed FROM tasks WHERE user_id = ? AND status = 'completed'", [uid]);

    // Weekly (last 7 days) daily breakdown
    const [weekly] = await pool.execute(`
      SELECT DATE(updated_at) AS day, COUNT(*) AS count
      FROM tasks
      WHERE user_id = ? AND status = 'completed'
        AND updated_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      GROUP BY DATE(updated_at)
      ORDER BY day ASC
    `, [uid]);

    // Streak — consecutive days with at least 1 completed task
    const [streakRows] = await pool.execute(`
      SELECT DISTINCT DATE(updated_at) AS day
      FROM tasks
      WHERE user_id = ? AND status = 'completed'
      ORDER BY day DESC
    `, [uid]);

    let streak = 0;
    if (streakRows.length) {
      const today = new Date(); today.setHours(0,0,0,0);
      for (let i = 0; i < streakRows.length; i++) {
        const d = new Date(streakRows[i].day); d.setHours(0,0,0,0);
        const expected = new Date(today); expected.setDate(today.getDate() - i);
        if (d.getTime() === expected.getTime()) streak++;
        else break;
      }
    }

    // Overdue tasks
    const [[{ overdue }]] = await pool.execute(`
      SELECT COUNT(*) AS overdue FROM tasks
      WHERE user_id = ? AND status = 'pending' AND deadline < NOW()
    `, [uid]);

    // By category
    const [byCategory] = await pool.execute(`
      SELECT category, COUNT(*) AS total,
             SUM(status = 'completed') AS completed_count
      FROM tasks WHERE user_id = ?
      GROUP BY category
    `, [uid]);

    res.json({
      success: true,
      stats: {
        todayCompleted,
        total,
        completed,
        completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
        streak,
        overdue,
        weekly,
        byCategory,
      },
    });
  } catch (err) {
    console.error('Stats error:', err);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

/* ────────────────────────────────────────────────────────────
   GET /api/tasks/:id   — single task
──────────────────────────────────────────────────────────── */
router.get('/:id', async (req, res) => {
  const uid = req.user.uid;
  try {
    const [[task]] = await pool.execute(
      'SELECT * FROM tasks WHERE id = ? AND user_id = ?', [req.params.id, uid]);
    if (!task) return res.status(404).json({ error: 'Task not found' });
    res.json({ success: true, task });
  } catch (err) {
    console.error('Get task error:', err);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

/* ────────────────────────────────────────────────────────────
   POST /api/tasks   — create task
──────────────────────────────────────────────────────────── */
router.post('/', async (req, res) => {
  const uid = req.user.uid;
  const { title, description, priority, category, deadline, status } = req.body;

  if (!title || title.trim() === '') {
    return res.status(400).json({ error: 'Title is required' });
  }

  const sql = `
    INSERT INTO tasks (user_id, title, description, priority, category, deadline, status)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
  const args = [
    uid,
    title.trim(),
    description   || null,
    priority      || 'medium',
    category      || 'Personal',
    deadline      || null,
    status        || 'pending',
  ];

  try {
    const [result] = await pool.execute(sql, args);
    const [[task]] = await pool.execute('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
    res.status(201).json({ success: true, task });
  } catch (err) {
    console.error('Create task error:', err);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

/* ────────────────────────────────────────────────────────────
   PUT /api/tasks/:id   — update task
──────────────────────────────────────────────────────────── */
router.put('/:id', async (req, res) => {
  const uid = req.user.uid;

  // First verify ownership
  const [[existing]] = await pool.execute(
    'SELECT id FROM tasks WHERE id = ? AND user_id = ?', [req.params.id, uid]);
  if (!existing) {
    return res.status(404).json({ error: 'Task not found or access denied' });
  }

  const { title, description, priority, category, deadline, status } = req.body;
  const sql = `
    UPDATE tasks SET
      title       = COALESCE(?, title),
      description = COALESCE(?, description),
      priority    = COALESCE(?, priority),
      category    = COALESCE(?, category),
      deadline    = COALESCE(?, deadline),
      status      = COALESCE(?, status)
    WHERE id = ? AND user_id = ?
  `;
  try {
    await pool.execute(sql, [title, description, priority, category, deadline, status, req.params.id, uid]);
    const [[task]] = await pool.execute('SELECT * FROM tasks WHERE id = ?', [req.params.id]);
    res.json({ success: true, task });
  } catch (err) {
    console.error('Update task error:', err);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

/* ────────────────────────────────────────────────────────────
   DELETE /api/tasks/:id   — delete task
──────────────────────────────────────────────────────────── */
router.delete('/:id', async (req, res) => {
  const uid = req.user.uid;
  try {
    const [result] = await pool.execute(
      'DELETE FROM tasks WHERE id = ? AND user_id = ?', [req.params.id, uid]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Task not found or access denied' });
    }
    res.json({ success: true, message: 'Task deleted' });
  } catch (err) {
    console.error('Delete task error:', err);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;
