import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _catCtrl   = TextEditingController();

  String    _priority = 'medium';
  String?   _category;
  DateTime? _deadline;
  bool      _isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.task!;
      _titleCtrl.text = t.title;
      _descCtrl.text  = t.description ?? '';
      _priority       = t.priority;
      _category       = t.category;
      _deadline       = t.deadline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final tasks = context.read<TaskProvider>();
      final uid   = auth.user!.id;

      if (isEditing) {
        await tasks.updateTask(widget.task!.copyWith(
          title:       _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          priority:    _priority,
          category:    _category ?? 'Personal',
          deadline:    _deadline,
        ));
      } else {
        await tasks.addTask(TaskModel(
          userId:      uid,
          title:       _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          priority:    _priority,
          category:    _category ?? 'Personal',
          deadline:    _deadline,
          status:      'pending',
          createdAt:   DateTime.now(),
        ));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:          Text('Error: $e'),
            backgroundColor:  Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _addCustomCategory(TaskProvider tasks) async {
    _catCtrl.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller:  _catCtrl,
          autofocus:   true,
          decoration:  const InputDecoration(hintText: 'Category name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, _catCtrl.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      tasks.addCategory(result);
      setState(() => _category = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tasks  = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon:      const Icon(Icons.delete_outline_rounded),
              tooltip:   'Delete task',
              color:     colors.error,
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('This task will be permanently deleted.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true && mounted) {
                  await tasks.deleteTask(widget.task!.id!);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller:  _titleCtrl,
                decoration:  const InputDecoration(
                  labelText:  'Task Title *',
                  hintText:   'What do you need to do?',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller:  _descCtrl,
                decoration:  const InputDecoration(
                  labelText:  'Description',
                  hintText:   'Add more details (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Priority
              const Text('Priority',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Row(
                children: ['high', 'medium', 'low'].map((p) {
                  final colors_ = {
                    'high':   Colors.red,
                    'medium': Colors.orange,
                    'low':    Colors.green,
                  }[p]!;
                  final isSelected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors_.withValues(alpha: 0.15)
                                : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? colors_ : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.flag_rounded, color: colors_, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                kPriorityLabels[p]!,
                                style: TextStyle(
                                  color:      colors_,
                                  fontWeight: FontWeight.w600,
                                  fontSize:   12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Category
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...tasks.categories.map((cat) => ChoiceChip(
                        label:    Text(cat),
                        selected: _category == cat,
                        onSelected: (v) => setState(() => _category = v ? cat : null),
                      )),
                  ActionChip(
                    label:    const Text('+ Custom'),
                    onPressed: () => _addCustomCategory(tasks),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Deadline
              const Text('Deadline',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: _deadline != null
                              ? colors.primary
                              : colors.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deadline != null
                              ? DateFormat('EEE, MMM d, yyyy · h:mm a')
                                  .format(_deadline!)
                              : 'Tap to set deadline',
                          style: TextStyle(
                            color: _deadline != null
                                ? colors.onSurface
                                : colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        IconButton(
                          icon:      const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _deadline = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(isEditing ? Icons.save_rounded : Icons.add_task_rounded),
                  label: Text(
                    _isSaving ? 'Saving…' : (isEditing ? 'Save Changes' : 'Create Task'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
