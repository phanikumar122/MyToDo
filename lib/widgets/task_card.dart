import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel    task;
  final VoidCallback? onTap;
  final VoidCallback? onFocus;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    final colors       = Theme.of(context).colorScheme;
    final taskProvider = context.read<TaskProvider>();
    final priorityColor = priorityColors[task.priority] ?? colors.primary;

    return Dismissible(
      key:             ValueKey(task.id),
      direction:       DismissDirection.endToStart,
      background:      _DeleteBackground(colors: colors),
      confirmDismiss:  (_) => _confirmDelete(context),
      onDismissed:     (_) {
        if (task.id != null) taskProvider.deleteTask(task.id!);
      },
      child: Card(
        child: InkWell(
          onTap:         onTap,
          borderRadius:  BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority indicator bar
                Container(
                  width:  4,
                  height: 52,
                  decoration: BoxDecoration(
                    color:        priorityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),

                // Checkbox
                GestureDetector(
                  onTap: () => taskProvider.toggleComplete(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape:  BoxShape.circle,
                      color:  task.isCompleted ? priorityColor : Colors.transparent,
                      border: Border.all(
                          color: task.isCompleted ? priorityColor : colors.outline,
                          width: 2),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize:   15,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? colors.onSurface.withOpacity(0.4)
                              : colors.onSurface,
                        ),
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color:    colors.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:        colors.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Deadline
                          if (task.deadline != null) ...[
                            Icon(
                              Icons.calendar_today_rounded,
                              size:  12,
                              color: task.isOverdue ? colors.error : colors.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat('MMM d').format(task.deadline!),
                              style: TextStyle(
                                fontSize: 11,
                                color: task.isOverdue
                                    ? colors.error
                                    : colors.onSurface.withOpacity(0.5),
                                fontWeight: task.isOverdue ? FontWeight.w600 : null,
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Overdue badge
                          if (task.isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:        colors.errorContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colors.error,
                                ),
                              ),
                            ),
                          // Focus button
                          if (onFocus != null && task.isPending)
                            IconButton(
                              icon:    const Icon(
                                  Icons.timer_outlined, size: 18),
                              tooltip: 'Focus mode',
                              color:   colors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onFocus,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final ColorScheme colors;
  const _DeleteBackground({required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color:        colors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      );
}
