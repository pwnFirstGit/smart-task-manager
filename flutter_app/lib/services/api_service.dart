import 'package:dio/dio.dart';
import '../models/task.dart';
import 'dio_client.dart';

class TaskApiException implements Exception {
  final String message;
  final int? statusCode;

  TaskApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio = DioClient().client;

  // Create a new task
  Future<Task> createTask(CreateTaskDto taskDto) async {
    try {
      final response = await _dio.post(
        '/api/tasks',
        data: taskDto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw TaskApiException(
          'Failed to create task: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get all tasks with filters
  Future<List<Task>> getTasks({
    TaskStatus? status,
    TaskCategory? category,
    TaskPriority? priority,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'limit': limit,
        'offset': offset,
      };

      if (status != null) queryParams['status'] = status.name;
      if (category != null) queryParams['category'] = category.name;
      if (priority != null) queryParams['priority'] = priority.name;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/tasks',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tasks = (data['tasks'] as List)
            .map((json) => Task.fromJson(json))
            .toList();
        return tasks;
      } else {
        throw TaskApiException(
          'Failed to fetch tasks: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get single task by ID
  Future<Task> getTask(String taskId) async {
    try {
      final response = await _dio.get('/api/tasks/$taskId');

      if (response.statusCode == 200) {
        return Task.fromJson(response.data['task']);
      } else {
        throw TaskApiException(
          'Failed to fetch task: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Update a task
  Future<Task> updateTask(String taskId, UpdateTaskDto updateDto) async {
    try {
      final response = await _dio.patch(
        '/api/tasks/$taskId',
        data: updateDto.toJson(),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw TaskApiException(
          'Failed to update task: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete('/api/tasks/$taskId');

      if (response.statusCode != 200) {
        throw TaskApiException(
          'Failed to delete task: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  TaskApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TaskApiException('Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return TaskApiException('No internet connection. Please check your network.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['error'] ?? error.response!.statusMessage;

      if (statusCode == 404) {
        return TaskApiException('Task not found', statusCode);
      } else if (statusCode == 400) {
        return TaskApiException('Invalid request: $message', statusCode);
      } else if (statusCode! >= 500) {
        return TaskApiException('Server error. Please try again later.', statusCode);
      }

      return TaskApiException(message ?? 'An error occurred', statusCode);
    }

    return TaskApiException('An unexpected error occurred: ${error.message}');
  }
}
