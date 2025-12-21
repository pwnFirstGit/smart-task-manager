import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

// Task Dashboard Screen - Main Screen
class TaskDashboardScreen extends ConsumerStatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  ConsumerState<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends ConsumerState<TaskDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final taskCounts = ref.watch(taskCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskListProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(taskListProvider.notifier).search('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  ref.read(taskListProvider.notifier).search(value);
                },
              ),
            ),

            // Summary Cards
            SummaryCards(counts: taskCounts),

            const SizedBox(height: 16),

            // Task List
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskItem(task: tasks[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(taskListProvider.notifier).refresh();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
      ),
    );
  }

  void _showCreateTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateTaskBottomSheet(),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

// Summary Cards Widget
class SummaryCards extends StatelessWidget {
  final Map<TaskStatus, int> counts;

  const SummaryCards({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              context,
              'Pending',
              counts[TaskStatus.pending] ?? 0,
              AppTheme.pendingColor,
              Icons.hourglass_empty,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(
              context,
              'In Progress',
              counts[TaskStatus.in_progress] ?? 0,
              AppTheme.inProgressColor,
              Icons.play_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(
              context,
              'Completed',
              counts[TaskStatus.completed] ?? 0,
              AppTheme.completedColor,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String label, int count, Color color, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          // Would filter by status
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Task Item Widget
class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetails(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Icon(
                    AppTheme.getStatusIcon(task.status.name),
                    color: AppTheme.getStatusColor(task.status.name),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(task.category.displayName),
                    backgroundColor: AppTheme.getCategoryColor(task.category.name).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: AppTheme.getCategoryColor(task.category.name),
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Chip(
                    avatar: Icon(
                      AppTheme.getPriorityIcon(task.priority.name),
                      size: 16,
                      color: AppTheme.getPriorityColor(task.priority.name),
                    ),
                    label: Text(task.priority.displayName),
                    backgroundColor: AppTheme.getPriorityColor(task.priority.name).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: AppTheme.getPriorityColor(task.priority.name),
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              if (task.dueDate != null || task.assignedTo != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(task.dueDate!),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (task.assignedTo != null) ...[
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        task.assignedTo!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailsBottomSheet(task: task),
    );
  }
}

// Create Task Bottom Sheet
class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  const CreateTaskBottomSheet({super.key});

  @override
  ConsumerState<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter task title',
                ),
                validator: validateTitle,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter task description',
                ),
                validator: validateDescription,
                maxLines: 3,
                maxLength: 2000,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assigned To',
                  hintText: 'Person name',
                ),
                validator: validateAssignedTo,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null
                    ? 'Select Due Date'
                    : DateFormat('MMM d, yyyy').format(_selectedDate!)),
                trailing: _selectedDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedDate = null),
                      )
                    : null,
                onTap: _selectDate,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitTask,
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskDto = CreateTaskDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _assignedToController.text.trim().isEmpty
            ? null
            : _assignedToController.text.trim(),
        dueDate: _selectedDate,
      );

      await ref.read(taskListProvider.notifier).createTask(taskDto);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Task Details Bottom Sheet
class TaskDetailsBottomSheet extends ConsumerWidget {
  final Task task;

  const TaskDetailsBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text('Are you sure you want to delete this task?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            try {
                              await ref.read(taskListProvider.notifier).deleteTask(task.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Task deleted')),
                                );
                              }
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $error')),
                                );
                              }
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(task.category.displayName),
                      backgroundColor: AppTheme.getCategoryColor(task.category.name).withOpacity(0.2),
                      labelStyle: TextStyle(color: AppTheme.getCategoryColor(task.category.name)),
                    ),
                    Chip(
                      avatar: Icon(
                        AppTheme.getPriorityIcon(task.priority.name),
                        size: 16,
                        color: AppTheme.getPriorityColor(task.priority.name),
                      ),
                      label: Text(task.priority.displayName),
                      backgroundColor: AppTheme.getPriorityColor(task.priority.name).withOpacity(0.2),
                      labelStyle: TextStyle(color: AppTheme.getPriorityColor(task.priority.name)),
                    ),
                    Chip(
                      label: Text(task.status.displayName),
                      backgroundColor: AppTheme.getStatusColor(task.status.name).withOpacity(0.2),
                      labelStyle: TextStyle(color: AppTheme.getStatusColor(task.status.name)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(task.description),
                const SizedBox(height: 24),
                if (task.suggestedActions.isNotEmpty) ...[
                  Text('Suggested Actions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...task.suggestedActions.map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(action)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
                if (task.dueDate != null || task.assignedTo != null) ...[
                  Text('Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (task.dueDate != null)
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Due Date',
                      DateFormat('MMM d, yyyy').format(task.dueDate!),
                    ),
                  if (task.assignedTo != null)
                    _buildDetailRow(Icons.person, 'Assigned To', task.assignedTo!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Tasks', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskStatus.values.map((status) {
              return FilterChip(
                label: Text(status.displayName),
                onSelected: (selected) {
                  ref.read(taskListProvider.notifier).applyFilters(
                        status: selected ? status : null,
                      );
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(taskListProvider.notifier).clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear Filters'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
