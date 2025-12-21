# Smart Task Manager - Backend

FastAPI backend with automatic task classification and intelligent organization.

## Features

- ✅ 5 RESTful API endpoints (Create, Read, Update, Delete, List)
- ✅ Automatic task classification (category, priority)
- ✅ Entity extraction (dates, people, locations, actions)
- ✅ Suggested actions generation
- ✅ Complete task history tracking
- ✅ Filtering, sorting, and pagination
- ✅ Full input validation
- ✅ Comprehensive unit tests

## Tech Stack

- **Framework**: FastAPI 0.109.0
- **Database**: Supabase (PostgreSQL)
- **Language**: Python 3.9+
- **Testing**: Pytest
- **Validation**: Pydantic

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Mac/Linux
pip install -r requirements.txt
```

### 2. Set Up Supabase Database

1. Go to [https://supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Go to SQL Editor and run the contents of `schema.sql`
4. Get your credentials from Settings > API:
   - Project URL
   - Anon/Public Key

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
PORT=8000
ENVIRONMENT=development
```

### 4. Run the Server

```bash
# From the backend directory
python -m uvicorn src.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`

### 5. View API Documentation

Open your browser and go to:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Running Tests

```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=src --cov-report=html
```

## Auto-Classification Examples

### Example 1: Scheduling Task
```
Input: "Schedule urgent meeting with team today about budget"

Output:
- Category: scheduling
- Priority: high (keywords: urgent, today)
- Entities: {dates: ["today"], people: ["team"], actions: ["Schedule"]}
- Actions: ["Block calendar time", "Send meeting invite", "Prepare meeting agenda"]
```

### Example 2: Technical Task
```
Input: "Fix critical bug in payment system asap"

Output:
- Category: technical (keywords: fix, bug, system)
- Priority: high (keywords: critical, asap)
- Entities: {actions: ["Fix"]}
- Actions: ["Diagnose the issue", "Check system resources", "Assign to technician"]
```

## Project Structure

```
backend/
├── src/
│   ├── __init__.py
│   ├── main.py          # FastAPI app and endpoints
│   ├── models.py        # Pydantic models
│   ├── database.py      # Supabase service
│   ├── classifier.py    # Auto-classification engine
│   └── config.py        # Configuration
├── tests/
│   ├── __init__.py
│   └── test_classifier.py   # Unit tests
├── requirements.txt     # Python dependencies
├── schema.sql          # Database schema
└── .env.example        # Environment template
```

## API Endpoints

See main README.md for complete API documentation.
