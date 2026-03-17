const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');
const Task = require('../models/task');
const { getNextSequence } = require('../models/counter');

router.use(verifyToken);

function serializeTask(task) {
  return {
    id: task.taskId,
    user_id: task.userId,
    title: task.title,
    description: task.description,
    priority: task.priority,
    category: task.category,
    deadline: task.deadline ? task.deadline.toISOString() : null,
    status: task.status,
    created_at: task.createdAt.toISOString(),
    updated_at: task.updatedAt ? task.updatedAt.toISOString() : null,
  };
}

function parseTaskId(idParam) {
  const id = Number.parseInt(idParam, 10);
  return Number.isNaN(id) ? null : id;
}

router.get('/', async (req, res) => {
  const uid = req.user.uid;
  const { status, priority, category } = req.query;

  const query = { userId: uid };
  if (status) query.status = status;
  if (priority) query.priority = priority;
  if (category) query.category = category;

  try {
    const tasks = await Task.find(query).sort({ deadline: 1, createdAt: -1 });
    res.json({ success: true, tasks: tasks.map(serializeTask) });
  } catch (err) {
    console.error('Get tasks error:', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

router.get('/stats', async (req, res) => {
  const uid = req.user.uid;

  try {
    const tasks = await Task.find({ userId: uid }).lean();
    const now = new Date();
    const today = new Date(now);
    today.setHours(0, 0, 0, 0);

    const todayCompleted = tasks.filter((task) => {
      if (task.status !== 'completed' || !task.updatedAt) return false;
      const updated = new Date(task.updatedAt);
      updated.setHours(0, 0, 0, 0);
      return updated.getTime() === today.getTime();
    }).length;

    const total = tasks.length;
    const completed = tasks.filter((task) => task.status === 'completed').length;
    const overdue = tasks.filter(
      (task) => task.status === 'pending' && task.deadline && new Date(task.deadline) < now
    ).length;

    const weeklyMap = new Map();
    for (let offset = 6; offset >= 0; offset -= 1) {
      const day = new Date(today);
      day.setDate(today.getDate() - offset);
      const key = day.toISOString().slice(0, 10);
      weeklyMap.set(key, 0);
    }

    for (const task of tasks) {
      if (task.status !== 'completed' || !task.updatedAt) continue;
      const key = new Date(task.updatedAt).toISOString().slice(0, 10);
      if (weeklyMap.has(key)) {
        weeklyMap.set(key, weeklyMap.get(key) + 1);
      }
    }

    const weekly = Array.from(weeklyMap.entries()).map(([day, count]) => ({ day, count }));

    const completedDays = new Set(
      tasks
        .filter((task) => task.status === 'completed' && task.updatedAt)
        .map((task) => new Date(task.updatedAt).toISOString().slice(0, 10))
    );

    let streak = 0;
    for (let offset = 0; ; offset += 1) {
      const day = new Date(today);
      day.setDate(today.getDate() - offset);
      const key = day.toISOString().slice(0, 10);
      if (!completedDays.has(key)) break;
      streak += 1;
    }

    const categoryMap = new Map();
    for (const task of tasks) {
      const key = task.category || 'Personal';
      const entry = categoryMap.get(key) || { category: key, total: 0, completed_count: 0 };
      entry.total += 1;
      if (task.status === 'completed') {
        entry.completed_count += 1;
      }
      categoryMap.set(key, entry);
    }

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
        byCategory: Array.from(categoryMap.values()),
      },
    });
  } catch (err) {
    console.error('Stats error:', err);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

router.get('/:id', async (req, res) => {
  const uid = req.user.uid;
  const taskId = parseTaskId(req.params.id);

  if (taskId === null) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  try {
    const task = await Task.findOne({ taskId, userId: uid });
    if (!task) return res.status(404).json({ error: 'Task not found' });
    res.json({ success: true, task: serializeTask(task) });
  } catch (err) {
    console.error('Get task error:', err);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

router.post('/', async (req, res) => {
  const uid = req.user.uid;
  const { title, description, priority, category, deadline, status } = req.body;

  if (!title || title.trim() === '') {
    return res.status(400).json({ error: 'Title is required' });
  }

  try {
    const taskId = await getNextSequence('tasks');
    const task = await Task.create({
      taskId,
      userId: uid,
      title: title.trim(),
      description: description || null,
      priority: priority || 'medium',
      category: category || 'Personal',
      deadline: deadline ? new Date(deadline) : null,
      status: status || 'pending',
    });

    res.status(201).json({ success: true, task: serializeTask(task) });
  } catch (err) {
    console.error('Create task error details:', err);
    res.status(500).json({ error: 'Failed to create task', details: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const uid = req.user.uid;
  const taskId = parseTaskId(req.params.id);

  if (taskId === null) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  try {
    const existing = await Task.findOne({ taskId, userId: uid });
    if (!existing) {
      return res.status(404).json({ error: 'Task not found or access denied' });
    }

    const { title, description, priority, category, deadline, status } = req.body;

    if (title !== undefined) existing.title = title;
    if (description !== undefined) existing.description = description;
    if (priority !== undefined) existing.priority = priority;
    if (category !== undefined) existing.category = category;
    if (deadline !== undefined) existing.deadline = deadline ? new Date(deadline) : null;
    if (status !== undefined) existing.status = status;

    await existing.save();

    res.json({ success: true, task: serializeTask(existing) });
  } catch (err) {
    console.error('Update task error:', err);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

router.delete('/:id', async (req, res) => {
  const uid = req.user.uid;
  const taskId = parseTaskId(req.params.id);

  if (taskId === null) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  try {
    const deletedTask = await Task.findOneAndDelete({ taskId, userId: uid });
    if (!deletedTask) {
      return res.status(404).json({ error: 'Task not found or access denied' });
    }
    res.json({ success: true, message: 'Task deleted' });
  } catch (err) {
    console.error('Delete task error:', err);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;
