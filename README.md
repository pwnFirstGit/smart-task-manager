# Smart Task Manager

> **Backend + Flutter Hybrid Developer Assessment**  
> A comprehensive task management system with automatic classification and intelligent organization

![Project Status](https://img.shields.io/badge/Status-Complete-success)
![Backend](https://img.shields.io/badge/Backend-FastAPI-009688)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B)
![Database](https://img.shields.io/badge/Database-Supabase-3ECF8E)
![Tests](https://img.shields.io/badge/Tests-17%2F17%20Passing-success)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Auto-Classification](#auto-classification)
- [Screenshots](#screenshots)
- [Testing](#testing)
- [Deployment](#deployment)
- [Architecture Decisions](#architecture-decisions)
- [What I'd Improve](#what-id-improve)

---

## 🎯 Overview

Smart Task Manager is a full-stack mobile application that automatically classifies and organizes tasks based on content analysis. When a user creates a task, the system automatically:

- **Detects category** (Scheduling, Finance, Technical, Safety, General)
- **Assigns priority** (High, Medium, Low) based on urgency indicators
- **Extracts entities** (dates, people, locations, action verbs)
- **Suggests actions** tailored to the task category

### Example

**Input:**
```
Title: "Schedule urgent meeting with team today about budget"
Description: "Need to discuss Q4 allocation with Sarah and John"
```

**Auto-Classification Output:**
```json
{
  "category": "scheduling",
  "priority": "high",
  "extracted_entities": {
    "dates": ["today"],
    "people": ["Sarah", "John"],
    "actions": ["Schedule", "discuss"]
  },
  "suggested_actions": [
    "Block calendar time",
    "Send meeting invite",
    "Prepare meeting agenda",
    "Set reminder notification"
  ]
}
```

---

## ✨ Features

### Backend API
- ✅ 5 RESTful API endpoints (CRUD operations)
- ✅ Intelligent auto-classification engine
- ✅ Entity extraction using NLP patterns
- ✅ Task history tracking (complete audit log)
- ✅ Advanced filtering, sorting, and pagination
- ✅ Comprehensive input validation (Pydantic)
- ✅ 17 unit tests (100% classification coverage)
- ✅ Supabase/PostgreSQL integration

### Flutter Mobile App
- ✅ Material Design 3 UI
- ✅ Task dashboard with summary cards
- ✅ Real-time search functionality
- ✅ Multi-criteria filtering
- ✅ Create/edit tasks with classification preview
- ✅ Pull-to-refresh
- ✅ Riverpod state management
- ✅ Form validation with error handling
- ✅ Loading states and error recovery
- ✅ Responsive design

---

## 🛠 Tech Stack

### Backend
| Technology | Purpose |
|------------|---------|
| **FastAPI** | Modern Python web framework |
| **Supabase** | PostgreSQL database with real-time capabilities |
| **Pydantic** | Data validation and settings management |
| **Pytest** | Unit testing framework |
| **Uvicorn** | ASGI server |

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Riverpod** | State management |
| **Dio** | HTTP client for API calls |
| **Material Design 3** | UI component library |
| **Intl** | Date/time formatting |

### Infrastructure
| Technology | Purpose |
|------------|---------|
| **Render.com** | Backend deployment |
| **Supabase** | Database hosting |
| **Git** | Version control |

---

## 📁 Project Structure

```
anti_gravity/
├── backend/                    # FastAPI Backend
│   ├── src/
│   │   ├── main.py            # FastAPI app & endpoints
│   │   ├── models.py          # Pydantic models
│   │   ├── database.py        # Supabase service
│   │   ├── classifier.py      # Auto-classification engine
│   │   └── config.py          # Configuration management
│   ├── tests/
│   │   └── test_classifier.py # Unit tests (17 tests)
│   ├── requirements.txt       # Python dependencies
│   ├── schema.sql             # Database schema
│   └── README.md
│
├── flutter_app/               # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── models/
│   │   │   └── task.dart      # Task models & DTOs
│   │   ├── providers/
│   │   │   └── task_provider.dart  # Riverpod providers
│   │   ├── services/
│   │   │   ├── dio_client.dart     # HTTP client
│   │   │   └── api_service.dart    # API calls
│   │   ├── screens/
│   │   │   └── task_dashboard_screen.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Material Design 3
│   │   └── utils/
│   │       ├── constants.dart
│   │       └── validators.dart
│   ├── pubspec.yaml
│   └── README.md
│
├── docs/                      # Documentation
│   ├── SUPABASE_SETUP.md     # Database setup guide
│   └── FLUTTER_SETUP.md      # Flutter installation
│
└── README.md                  # This file
```

---

## 🚀 Quick Start

### Prerequisites

- Python 3.9+
- Flutter SDK 3.0+ (optional for now)
- Supabase account
- Git

### 1. Clone Repository

```bash
git clone <your-repo-url>
cd anti_gravity
```

### 2. Set Up Database

Follow the guide in `docs/SUPABASE_SETUP.md`:

1. Create free Supabase account at https://supabase.com
2. Create new project
3. Run `backend/schema.sql` in SQL Editor
4. Copy Project URL and API Key

### 3. Set Up Backend

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and add your Supabase credentials

# Run tests
pytest tests/ -v

# Start server
python -m uvicorn src.main:app --reload
```

Backend will be available at `http://localhost:8000`

### 4. Set Up Flutter (Optional)

See `docs/FLUTTER_SETUP.md` for Flutter installation.

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Update API URL in lib/utils/constants.dart

# Run app
flutter run
```

---

## 📚 API Documentation

### Base URL
```
Development: http://localhost:8000
Production: https://smart-task-manager-3z9n.onrender.com
```

### Endpoints

#### 1. Create Task
```http
POST /api/tasks
Content-Type: application/json

{
  "title": "Schedule urgent meeting",
  "description": "Discuss Q4 budget with team",
  "assigned_to": "John Doe",
  "due_date": "2025-12-22T14:00:00Z"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "title": "Schedule urgent meeting",
  "description": "Discuss Q4 budget with team",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "assigned_to": "John Doe",
  "due_date": "2025-12-22T14:00:00Z",
  "extracted_entities": {
    "dates": [],
    "people": ["team"],
    "locations": [],
    "actions": ["Schedule"]
  },
  "suggested_actions": [
    "Block calendar time",
    "Send meeting invite",
    "Prepare meeting agenda"
  ],
  "created_at": "2025-12-21T10:00:00Z",
  "updated_at": "2025-12-21T10:00:00Z"
}
```

#### 2. List Tasks
```http
GET /api/tasks?status=pending&priority=high&limit=10&offset=0
```

**Query Parameters:**
- `status`: pending | in_progress | completed
- `category`: scheduling | finance | technical | safety | general
- `priority`: high | medium | low
- `search`: text search in title/description
- `sort_by`: field name (default: created_at)
- `sort_order`: asc | desc (default: desc)
- `limit`: 1-100 (default: 20)
- `offset`: pagination offset (default: 0)

**Response (200):**
```json
{
  "tasks": [...],
  "total": 45,
  "limit": 10,
  "offset": 0,
  "has_more": true
}
```

#### 3. Get Task Details
```http
GET /api/tasks/{task_id}
```

**Response (200):**
```json
{
  "task": { ... },
  "history": [
    {
      "action": "created",
      "changed_by": "system",
      "changed_at": "2025-12-21T10:00:00Z",
      "new_value": { ... }
    }
  ]
}
```

#### 4. Update Task
```http
PATCH /api/tasks/{task_id}
Content-Type: application/json

{
  "status": "in_progress",
  "assigned_to": "Jane Smith"
}
```

**Response (200):** Updated task object

#### 5. Delete Task
```http
DELETE /api/tasks/{task_id}
```

**Response (200):**
```json
{
  "message": "Task deleted successfully",
  "task_id": "uuid"
}
```

### Interactive API Documentation

Once the backend is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🗄 Database Schema

### Tables

#### `tasks`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| title | TEXT | Task title (required) |
| description | TEXT | Task description |
| category | TEXT | scheduling, finance, technical, safety, general |
| priority | TEXT | high, medium, low |
| status | TEXT | pending, in_progress, completed |
| assigned_to | TEXT | Assignee name |
| due_date | TIMESTAMPTZ | Due date |
| extracted_entities | JSONB | Extracted dates, people, locations, actions |
| suggested_actions | JSONB | Array of suggested action strings |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

**Indexes:**
- `idx_tasks_status` on status
- `idx_tasks_category` on category
- `idx_tasks_priority` on priority
- `idx_tasks_due_date` on due_date

#### `task_history`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| task_id | UUID | Foreign key to tasks |
| action | TEXT | created, updated, status_changed, completed |
| old_value | JSONB | Previous task state |
| new_value | JSONB | New task state |
| changed_by | TEXT | User who made the change |
| changed_at | TIMESTAMPTZ | Change timestamp |

**Relationships:**
- `task_id` references `tasks(id)` ON DELETE CASCADE

---

## 🤖 Auto-Classification

### Category Detection Algorithm

Uses keyword matching across title + description:

| Category | Keywords |
|----------|----------|
| **Scheduling** | meeting, schedule, call, appointment, deadline, calendar |
| **Finance** | payment, invoice, bill, budget, cost, expense, purchase |
| **Technical** | bug, fix, error, install, repair, maintain, update, code |
| **Safety** | safety, hazard, inspection, compliance, PPE, risk |
| **General** | Default if no matches |

### Priority Assignment Algorithm

1. **Keyword-based:**
   - High: urgent, asap, immediately, today, critical, emergency
   - Medium: soon, this week, important, priority
   - Low: default

2. **Due date-based:**
   - Due < 24 hours → High
   - Due < 7 days → Medium
   - Otherwise → Low (or keyword-based)

### Entity Extraction

- **Dates:** Regex patterns for "today", "tomorrow", date formats
- **People:** Names after "with", "by", "assign to", "for"
- **Locations:** Words after "at", "in", room/office references
- **Actions:** Common action verbs (schedule, send, prepare, review, etc.)

### Suggested Actions

Category-specific action templates:

```python
{
  "scheduling": ["Block calendar", "Send invite", "Prepare agenda", "Set reminder"],
  "finance": ["Check budget", "Get approval", "Generate invoice", "Update records"],
  "technical": ["Diagnose issue", "Check resources", "Assign technician", "Document fix"],
  "safety": ["Conduct inspection", "File report", "Notify supervisor", "Update checklist"]
}
``` 

---

## 🧪 Testing

### Backend Tests

```bash
cd backend
source venv/bin/activate
pytest tests/ -v
```

**Test Coverage:**
- ✅ 5 Category classification tests
- ✅ 5 Priority assignment tests
- ✅ 4 Entity extraction tests
- ✅ 3 Suggested actions tests

**Results:** 17/17 tests passing

### Manual Testing Checklist

- [x] Create task with auto-classification
- [x] List tasks with filters
- [x] Search tasks
- [x] Update task
- [x] Delete task
- [x] View task history
- [x] Pagination works
- [x] Error handling
- [x] Input validation

---

## 🚢 Deployment

### Deploy Backend to Render.com

1. **Create Render Account:** https://render.com

2. **Create New Web Service:**
   - Connect GitHub repository
   - Select `backend` directory as root
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`

3. **Set Environment Variables:**
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   ENVIRONMENT=production
   ```

4. **Deploy** and note the live URL: `https://smart-task-manager-3z9n.onrender.com`

5. **Update Flutter App:**
   - Edit `flutter_app/lib/utils/constants.dart`
   - Change `kApiBaseUrl` to your Render URL

### Test Deployment

```bash
curl https://your-app.onrender.com/
# Should return: {"message": "Smart Task Manager API", "status": "running"}

curl -X POST https://your-app.onrender.com/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Testing deployment"}'
```

---

## 🏗 Architecture Decisions

### Why FastAPI over Node.js?

✅ **Built-in validation** with Pydantic → Less boilerplate  
✅ **Automatic API docs** → Faster development  
✅ **Type safety** → Fewer runtime errors  
✅ **Performance** → Comparable to Node.js  
✅ **Python ecosystem** → Easy integration with NLP libraries

### Why Riverpod over Provider?

✅ **Compile-time safety** → Catch errors earlier  
✅ **Better testability** → No BuildContext required  
✅ **Provider composition** → More flexible architecture  
✅ **Future-proof** → Recommended by Flutter team

### Why Supabase?

✅ **PostgreSQL** → Powerful relational features  
✅ **Real-time subscriptions** → Future enhancement ready  
✅ **Free tier** → Perfect for assessment  
✅ **RESTful API** → Easy Python integration  
✅ **Built-in auth** → Expandable for security

### Classification Approach

Used **keyword-based matching** instead of ML because:
- ✅ **Deterministic** → Predictable results
- ✅ **No training data** → Works immediately
- ✅ **Lightweight** → Fast response times
- ✅ **Transparent** → Easy to debug and explain
- ✅ **Customizable** → Easy to add keywords

For production, could upgrade to:
- spaCy for NER (Named Entity Recognition)
- Sentence transformers for semantic similarity
- OpenAI API for GPT-based classification

---

## 💡 What I'd Improve

Given more time, I would add:

### Backend Enhancements
- [ ] **User authentication** → JWT-based auth with Supabase
- [ ] **Rate limiting** → Prevent API abuse
- [ ] **Caching** → Redis for frequently accessed tasks
- [ ] **Background jobs** → Celery for async processing
- [ ] **WebSocket support** → Real-time task updates
- [ ] **Machine learning** → Replace keywords with NLP model
- [ ] **API versioning** → `/api/v1/tasks` for backwards compatibility
- [ ] **Comprehensive logging** → Structured logs with ELK stack

### Flutter Enhancements
- [ ] **Dark mode** → Theme toggle
- [ ] **Offline support** → Local database with Hive/Drift
- [ ] **Push notifications** → Firebase Cloud Messaging
- [ ] **Task attachments** → File upload support
- [ ] **Collaborative features** → Task sharing and comments
- [ ] **Analytics** → User behavior tracking
- [ ] **Accessibility** → Screen reader support
- [ ] **Animations** → Hero transitions, shimmer effects

### Infrastructure
- [ ] **CI/CD pipeline** → GitHub Actions for automated testing/deployment
- [ ] **Docker** → Containerization for consistent environments
- [ ] **Monitoring** → Sentry for error tracking
- [ ] **Performance monitoring** → New Relic or DataDog
- [ ] **Load balancing** → Multiple backend instances
- [ ] **CDN** → CloudFlare for static assets

### Features
- [ ] **Recurring tasks** → Scheduled task creation
- [ ] **Task templates** → Pre-defined task structures
- [ ] **Bulk operations** → Batch create/update/delete
- [ ] **Export/Import** → CSV, JSON formats
- [ ] **Integrations** → Google Calendar, Slack, Email
- [ ] **Custom fields** → User-defined task attributes
- [ ] **Reports** → Task analytics and insights

---

## 📸 Screenshots

Expected screens:
1. Dashboard with summary cards : [Screenshots/dashboard with summary.png)](https://github.com/pwnFirstGit/smart-task-manager/blob/main/Screenshots/dashboard%20with%20summary.png)
2. Task list with filters : [Screenshots/task-list-with-filter.png)](https://github.com/pwnFirstGit/smart-task-manager/blob/main/Screenshots/task-list-with-filter.png)
3. Create task form with classification preview : [Screenshots/create-task-form.png)
](https://github.com/pwnFirstGit/smart-task-manager/blob/main/Screenshots/create-task-form.png)
4. Task details view : [Screenshots/task-details-view.png)](https://github.com/pwnFirstGit/smart-task-manager/blob/main/Screenshots/task-details-view.png)
5. Search and filter UI : [Screenshots/search-and-filter.png)](https://github.com/pwnFirstGit/smart-task-manager/blob/main/Screenshots/search-and-filter.png)

---

## Assessment Checklist

### Deliverables
- [x] Backend API with 5 endpoints
- [x] Supabase database with 2 tables
- [x] Flutter app with dashboard screen
- [ ] Backend deployed to Render.com (awaiting Supabase setup)
- [x] Comprehensive README
- [x] Minimum 3 unit tests (17 total)

### Code Quality
- [x] Clean project structure
- [x] Proper error handling
- [x] Input validation
- [x] Code comments
- [x] Type safety
- [x] Meaningful variable names

### Documentation
- [x] Project overview
- [x] Tech stack
- [x] Setup instructions
- [x] API documentation
- [x] Database schema
- [x] Architecture decisions
- [x] Improvement suggestions

---

##  Author

Pawan Kumar Dangi 
Backend + Flutter Hybrid Developer

---

##  License

This project is created for assessment purposes.

---

## Acknowledgments
- FastAPI documentation and community
- Flutter & Riverpod documentation
- Supabase for excellent PostgreSQL tooling
- Material Design 3 guidelines

---

**Live Demo:** https://smart-task-manager-3z9n.onrender.com/docs

**Contact:** pawanforyou18@gmail.com / 6267385961
