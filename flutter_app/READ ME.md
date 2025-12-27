# Smart Task Manager - Flutter App

Material Design 3 Flutter mobile app with automatic task classification.

## Features

- ✅ Task Dashboard with summary cards
- ✅ Task list with filtering and search
- ✅ Create/Edit tasks with auto-classification preview
- ✅ Pull-to-refresh
- ✅ Material Design 3 UI
- ✅ Riverpod state management
- ✅ Form validation
- ✅ Error handling with user-friendly messages
- ✅ Offline indicator
- ✅ Loading states and shimmer effects

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- iOS Simulator or Android Emulator (or physical device)

## Installation

### 1. Install Flutter

See `../docs/FLUTTER_SETUP.md` for installation instructions.

### 2. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/utils/constants.dart` and set the API URL:

```dart
// For local development
const String kApiBaseUrl = 'http://localhost:8000';

// For production (after deploying backend to Render)
const String kApiBaseUrl = 'https://your-app.onrender.com';
```

**Important for iOS Simulator**: Local host should be `http://localhost:8000`  
**Important for Android Emulator**: Use `http://10.0.2.2:8000` instead of localhost

## Running the App

### Start Backend First

```bash
# In terminal 1 - Start backend
cd ../backend
source venv/bin/activate
python -m uvicorn src.main:app --reload
```

### Run Flutter App

```bash
# In terminal 2 - Run Flutter app
cd flutter_app

# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run (will prompt for device selection)
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── task.dart               # Task models and DTOs
├── providers/
│   └── task_provider.dart      # Riverpod state management
├── services/
│   ├── dio_client.dart         # HTTP client
│   └── api_service.dart        # API calls
├── screens/
│   └── task_dashboard_screen.dart  # Main screen with all widgets
├── theme/
│   └── app_theme.dart          # Material Design 3 theme
└── utils/
    ├── constants.dart          # API configuration
    └── validators.dart         # Form validation
```

## Features Walkthrough

### 1. Dashboard
- View task counts by status (Pending, In Progress, Completed)
- Quick overview of all tasks
- Pull down to refresh

### 2. Task List
- All tasks in card format
- Color-coded by category and priority
- Shows due date and assigned person
- Tap to view details

### 3. Search
- Real-time search across titles and descriptions
- Debounced for performance

### 4. Filters
- Filter by status, category, or priority
- Clear all filters option

### 5. Create Task
- Fill in title and description (required)
- Optional: assigned person and due date
- Auto-classification shows category, priority, entities, and suggested actions
- Form validation with helpful error messages

### 6. Task Details
- View complete task information
- See all suggested actions
- Delete task option

## Troubleshooting

### Cannot connect to backend

**iOS Simulator**:
```dart
const String kApiBaseUrl = 'http://localhost:8000';
```

**Android Emulator**:
```dart
const String kApiBaseUrl = 'http://10.0.2.2:8000';
```

**Physical Device** (on same network):
```dart
const String kApiBaseUrl = 'http://YOUR_COMPUTER_IP:8000';  // e.g., http://192.168.1.100:8000
```

### Dependency errors

```bash
flutter clean
flutter pub get
```

### Build errors

```bash
flutter doctor
flutter doctor --android-licenses  # For Android
```

## Testing

The main automated tests are in the backend. For Flutter, manual testing covers:

- ✅ Create task
- ✅ View task list
- ✅ Search tasks
- ✅ Filter tasks
- ✅ View task details
- ✅ Delete task
- ✅ Pull to refresh
- ✅ Error handling
- ✅ Form validation



