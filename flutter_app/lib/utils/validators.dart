import '../../models/task.dart';

String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Title is required';
  }
  if (value.trim().length > 200) {
    return 'Title must be 200 characters or less';
  }
  return null;
}

String? validateDescription(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Description is required';
  }
  if (value.trim().length > 2000) {
    return 'Description must be 2000 characters or less';
  }
  return null;
}

String? validateAssignedTo(String? value) {
  if (value != null && value.trim().length > 100) {
    return 'Assigned to must be 100 characters or less';
  }
  return null;
}
