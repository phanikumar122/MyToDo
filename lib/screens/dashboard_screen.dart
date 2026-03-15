import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_ring.dart';
import 'add_edit_task_screen.dart';
import 'focus_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final colors = Theme.of(context).colorScheme;
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => tasks.loadTasks(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${auth.user?.name.split(' ').first ?? 'there'}! 👋',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  Text(
                    today,
                    style: TextStyle(
                      fontSize: 14,
                      color:    colors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                if (auth.user?.profilePicture != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(auth.user!.profilePicture!),
                      radius: 18,
                    ),
                  ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Progress summary card ─────────────────
                  _SummaryCard(tasks: tasks),
                  const SizedBox(height: 20),

                  // ── Overdue banner ────────────────────────
                  if (tasks.overdueTasks.isNotEmpty)
                    _OverdueBanner(count: tasks.overdueTasks.length),
                  if (tasks.overdueTasks.isNotEmpty)
                    const SizedBox(height: 16),

                  // ── Today's tasks ─────────────────────────
                  _SectionHeader(
                    title:    "Today's Tasks",
                    count:    tasks.todayTasks.length,
                    subtitle: '${tasks.pendingTasks.length} pending',
                  ),
                  const SizedBox(height: 8),
                  if (tasks.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (tasks.todayTasks.isEmpty)
                    const _EmptyState(
                      icon:    Icons.today_rounded,
                      message: 'No tasks due today — you\'re all caught up! 🎉',
                    )
                  else
                    ...tasks.todayTasks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: t,
                            onTap:    () => _editTask(context, t),
                            onFocus:  () => _focusTask(context, t),
                          ),
                        )),
                  const SizedBox(height: 20),

                  // ── Upcoming deadlines ────────────────────
                  if (tasks.upcomingTasks.isNotEmpty) ...[
                    _SectionHeader(
                      title:    'Upcoming Deadlines',
                      count:    tasks.upcomingTasks.take(5).length,
                    ),
                    const SizedBox(height: 8),
                    ...tasks.upcomingTasks.take(5).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: t,
                            onTap:   () => _editTask(context, t),
                            onFocus: () => _focusTask(context, t),
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],

                  // ── Completed today ───────────────────────
                  if (tasks.completedTasks.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Completed',
                      count: tasks.completedTasks.length,
                    ),
                    const SizedBox(height: 8),
                    ...tasks.completedTasks.take(3).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(task: t, onTap: () => _editTask(context, t)),
                        )),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext ctx, TaskModel t) => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: t)),
      );

  void _focusTask(BuildContext ctx, TaskModel t) => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => FocusScreen(task: t)),
      );
}

// ── Summary card with progress ring ──────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final TaskProvider tasks;
  const _SummaryCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total     = tasks.tasks.length;
    final completed = tasks.completedTasks.length;
    final streak    = tasks.stats?['streak'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProgressRing(
              progress: tasks.completionRate,
              size:     90,
              strokeWidth: 8,
              centerText: '${(tasks.completionRate * 100).toInt()}%',
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatRow(icon: Icons.check_circle_rounded,
                      label: 'Completed', value: '$completed / $total',
                      color: Colors.green),
                  const SizedBox(height: 4),
                  _StatRow(icon: Icons.pending_actions_rounded,
                      label: 'Overdue',
                      value: '${tasks.overdueTasks.length}',
                      color: Colors.red),
                  const SizedBox(height: 4),
                  _StatRow(icon: Icons.local_fire_department_rounded,
                      label: 'Streak',
                      value: '${streak}d',
                      color: Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  const _StatRow({required this.icon, required this.label,
                  required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  final int count;
  const _OverdueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count task${count > 1 ? 's are' : ' is'} overdue!',
              style: TextStyle(
                  color: colors.onErrorContainer, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int?   count;
  final String? subtitle;
  const _SectionHeader({required this.title, this.count, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:        colors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer)),
          ),
        ],
        if (subtitle != null) ...[
          const Spacer(),
          Text(subtitle!, style: TextStyle(
              fontSize: 12, color: colors.onSurface.withValues(alpha: 0.5))),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String   message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
