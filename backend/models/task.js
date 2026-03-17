const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema(
  {
    taskId: {
      type: Number,
      required: true,
      unique: true,
      index: true,
    },
    userId: {
      type: String,
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      default: null,
    },
    priority: {
      type: String,
      enum: ['high', 'medium', 'low'],
      default: 'medium',
    },
    category: {
      type: String,
      default: 'Personal',
      trim: true,
    },
    deadline: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ['pending', 'completed'],
      default: 'pending',
    },
  },
  {
    timestamps: true,
    versionKey: false,
    collection: 'tasks',
  }
);

taskSchema.index({ userId: 1, status: 1, deadline: 1 });
taskSchema.index({ userId: 1, category: 1 });

module.exports = mongoose.models.Task || mongoose.model('Task', taskSchema);
