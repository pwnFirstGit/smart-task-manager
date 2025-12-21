// Task model matching the backend schema
class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final DateTime? dueDate;
  final ExtractedEntities extractedEntities;
  final List<String> suggestedActions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.dueDate,
    required this.extractedEntities,
    required this.suggestedActions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TaskCategory.values.byName(json['category'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
      status: TaskStatus.values.byName(json['status'] as String),
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String) 
          : null,
      extractedEntities: ExtractedEntities.fromJson(
        json['extracted_entities'] as Map<String, dynamic>
      ),
      suggestedActions: List<String>.from(json['suggested_actions'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
      'extracted_entities': extractedEntities.toJson(),
      'suggested_actions': suggestedActions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum TaskCategory {
  scheduling,
  finance,
  technical,
  safety,
  general;

  String get displayName {
    switch (this) {
      case TaskCategory.scheduling:
        return 'Scheduling';
      case TaskCategory.finance:
        return 'Finance';
      case TaskCategory.technical:
        return 'Technical';
      case TaskCategory.safety:
        return 'Safety';
      case TaskCategory.general:
        return 'General';
    }
  }
}

enum TaskPriority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}

enum TaskStatus {
  pending,
  in_progress,
  completed;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.in_progress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

class ExtractedEntities {
  final List<String> dates;
  final List<String> people;
  final List<String> locations;
  final List<String> actions;

  ExtractedEntities({
    required this.dates,
    required this.people,
    required this.locations,
    required this.actions,
  });

  factory ExtractedEntities.fromJson(Map<String, dynamic> json) {
    return ExtractedEntities(
      dates: List<String>.from(json['dates'] ?? []),
      people: List<String>.from(json['people'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
      actions: List<String>.from(json['actions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dates': dates,
      'people': people,
      'locations': locations,
      'actions': actions,
    };
  }
}

class CreateTaskDto {
  final String title;
  final String description;
  final String? assignedTo;
  final DateTime? dueDate;

  CreateTaskDto({
    required this.title,
    required this.description,
    this.assignedTo,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}

class UpdateTaskDto {
  final String? title;
  final String? description;
  final TaskCategory? category;
  final TaskPriority? priority;
  final TaskStatus? status;
  final String? assignedTo;
  final DateTime? dueDate;

  UpdateTaskDto({
    this.title,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.assignedTo,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (category != null) json['category'] = category!.name;
    if (priority != null) json['priority'] = priority!.name;
    if (status != null) json['status'] = status!.name;
    if (assignedTo != null) json['assigned_to'] = assignedTo;
    if (dueDate != null) json['due_date'] = dueDate!.toIso8601String();
    return json;
  }
}
