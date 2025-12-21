import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Task List Provider with filters
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TaskListNotifier(apiService);
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;
  TaskStatus? _statusFilter;
  TaskCategory? _categoryFilter;
  TaskPriority? _priorityFilter;
  String? _searchQuery;

  TaskListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _apiService.getTasks(
        status: _statusFilter,
        category: _categoryFilter,
        priority: _priorityFilter,
        search: _searchQuery,
      );
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void applyFilters({
    TaskStatus? status,
    TaskCategory? category,
    TaskPriority? priority,
  }) {
    _statusFilter = status;
    _categoryFilter = category;
    _priorityFilter = priority;
    fetchTasks();
  }

  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _priorityFilter = null;
    _searchQuery = null;
    fetchTasks();
  }

  void search(String query) {
    _searchQuery = query.isEmpty ? null : query;
    fetchTasks();
  }

  Future<void> createTask(CreateTaskDto taskDto) async {
    try {
      await _apiService.createTask(taskDto);
      await fetchTasks();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, UpdateTaskDto updateDto) async {
    try {
      await _apiService.updateTask(taskId, updateDto);
      await fetchTasks();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      await fetchTasks();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchTasks();
  }
}

// Task counts provider
final taskCountsProvider = Provider<Map<TaskStatus, int>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      final counts = <TaskStatus, int>{
        TaskStatus.pending: 0,
        TaskStatus.in_progress: 0,
        TaskStatus.completed: 0,
      };
      
      for (final task in tasks) {
        counts[task.status] = (counts[task.status] ?? 0) + 1;
      }
      
      return counts;
    },
    loading: () => {
      TaskStatus.pending: 0,
      TaskStatus.in_progress: 0,
      TaskStatus.completed: 0,
    },
    error: (_, __) => {
      TaskStatus.pending: 0,
      TaskStatus.in_progress: 0,
      TaskStatus.completed: 0,
    },
  );
});

// Active filters provider
final activeFiltersProvider = StateProvider<ActiveFilters>((ref) {
  return ActiveFilters();
});

class ActiveFilters {
  final TaskStatus? status;
  final TaskCategory? category;
  final TaskPriority? priority;

  ActiveFilters({
    this.status,
    this.category,
    this.priority,
  });

  bool get hasFilters => status != null || category != null || priority != null;

  ActiveFilters copyWith({
    TaskStatus? status,
    TaskCategory? category,
    TaskPriority? priority,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearPriority = false,
  }) {
    return ActiveFilters(
      status: clearStatus ? null : (status ?? this.status),
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }
}
