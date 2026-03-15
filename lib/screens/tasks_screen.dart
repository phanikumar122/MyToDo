import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'focus_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? _filterStatus;
  String? _filterPriority;
  String? _filterCategory;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks   = context.watch<TaskProvider>();
    final colors  = Theme.of(context).colorScheme;
    final filtered = tasks.filterTasks(
      status:      _filterStatus,
      priority:    _filterPriority,
      category:    _filterCategory,
      searchQuery: _searchCtrl.text,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon:      const Icon(Icons.filter_list_rounded),
            tooltip:   'Filter Tasks',
            onPressed: () => _showFilterSheet(context, tasks),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller:  _searchCtrl,
              decoration:  const InputDecoration(
                hintText:    'Search tasks…',
                prefixIcon:  Icon(Icons.search_rounded),
                suffixIcon:  null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Active filter chips
          if (_filterStatus != null || _filterPriority != null || _filterCategory != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 6,
                children: [
                  if (_filterStatus != null)
                    _FilterChip(
                      label:    _filterStatus!,
                      onDelete: () => setState(() => _filterStatus = null),
                    ),
                  if (_filterPriority != null)
                    _FilterChip(
                      label:    _filterPriority!,
                      onDelete: () => setState(() => _filterPriority = null),
                    ),
                  if (_filterCategory != null)
                    _FilterChip(
                      label:    _filterCategory!,
                      onDelete: () => setState(() => _filterCategory = null),
                    ),
                ],
              ),
            ),
          // Task list
          Expanded(
            child: tasks.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 64,
                                color: colors.onSurface.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text('No tasks found',
                                style: TextStyle(
                                    color: colors.onSurface.withValues(alpha: 0.4),
                                    fontSize: 16)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => tasks.loadTasks(),
                        child: ListView.builder(
                          padding:     const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount:   filtered.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskCard(
                              task:    filtered[i],
                              onTap:   () => _editTask(context, filtered[i]),
                              onFocus: () => _focusTask(context, filtered[i]),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
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

  void _showFilterSheet(BuildContext ctx, TaskProvider tasks) async {
    String? tmpStatus   = _filterStatus;
    String? tmpPriority = _filterPriority;
    String? tmpCategory = _filterCategory;

    await showModalBottomSheet(
      context: ctx,
      shape:   const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (c, setSBState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Filter Tasks',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Status'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: ['pending', 'completed'].map((s) =>
                ChoiceChip(
                  label:    Text(s),
                  selected: tmpStatus == s,
                  onSelected: (v) => setSBState(() => tmpStatus = v ? s : null),
                )).toList()),
              const SizedBox(height: 12),
              const Text('Priority'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: ['high', 'medium', 'low'].map((p) =>
                ChoiceChip(
                  label:    Text(p),
                  selected: tmpPriority == p,
                  onSelected: (v) => setSBState(() => tmpPriority = v ? p : null),
                )).toList()),
              const SizedBox(height: 12),
              const Text('Category'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: tasks.categories.map((cat) =>
                ChoiceChip(
                  label:    Text(cat),
                  selected: tmpCategory == cat,
                  onSelected: (v) => setSBState(() => tmpCategory = v ? cat : null),
                )).toList()),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = _filterPriority = _filterCategory = null;
                      });
                      Navigator.pop(c);
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus   = tmpStatus;
                        _filterPriority = tmpPriority;
                        _filterCategory = tmpCategory;
                      });
                      Navigator.pop(c);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String   label;
  final VoidCallback onDelete;
  const _FilterChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label:           Text(label),
      deleteIcon:      const Icon(Icons.close, size: 14),
      onDeleted:       onDelete,
      backgroundColor: colors.primaryContainer,
      labelStyle:      TextStyle(color: colors.onPrimaryContainer, fontSize: 12),
    );
  }
}
