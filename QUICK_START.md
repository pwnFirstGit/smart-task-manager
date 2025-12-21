# ⚡ Quick Start Guide - 5 Minutes to Running App

## 🎯 Goal
Get your Smart Task Manager backend running in 5 minutes!

---

## Step 1: Set Up Supabase (2 minutes)

1. **Go to:** https://supabase.com
2. **Click:** "Start your project" → Sign up with GitHub
3. **Click:** "New Project"
4. **Fill in:**
   - Name: `smart-task-manager`
   - Database Password: (create strong password - **SAVE IT!**)
   - Region: (closest to you)
5. **Wait:** ~1 minute for project creation

---

## Step 2: Create Database (1 minute)

1. **In Supabase, click:** "SQL Editor" (left sidebar)
2. **Click:** "New query"
3. **Open file:** `backend/schema.sql` on your computer
4. **Copy:** ALL the contents (Cmd+A, Cmd+C)
5. **Paste:** Into Supabase SQL Editor
6. **Click:** "Run" button (or Cmd+Enter)
7. **Verify:** You see "Database schema created successfully!"

---

## Step 3: Get API Credentials (30 seconds)

1. **In Supabase, click:** "Settings" (gear icon, left sidebar)
2. **Click:** "API"
3. **Copy these TWO values:**
   - ✅ **Project URL** (looks like `https://xxxxx.supabase.co`)
   - ✅ **anon public key** (long string under "Project API keys")

---

## Step 4: Configure Backend (30 seconds)

1. **Open file:** `backend/.env` in a text editor
2. **Replace the placeholder values:**
   ```
   SUPABASE_URL=https://xxxxx.supabase.co    ← Paste YOUR Project URL
   SUPABASE_KEY=eyJxxx...                     ← Paste YOUR anon key
   PORT=8000
   ENVIRONMENT=development
   ```
3. **Save the file**

---

## Step 5: Start Backend (1 minute)

```bash
# Open Terminal
cd /Users/pawan/Desktop/anti_gravity/backend

# Activate virtual environment
source venv/bin/activate

# Start server
python -m uvicorn src.main:app --reload
```

**Expected output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

---

## ✅ Verification

1. **Open browser:** http://localhost:8000
   - Should see: `{"message": "Smart Task Manager API", "status": "running"}`

2. **View API docs:** http://localhost:8000/docs
   - Should see interactive Swagger documentation

3. **Test creating a task:**
   - In Swagger docs, click "POST /api/tasks"
   - Click "Try it out"
   - Use this example:
     ```json
     {
       "title": "Test task",
       "description": "This is a test" 
     }
     ```
   - Click "Execute"
   - Should see 201 response with auto-classification!

---

## 🎉 Success!

Your backend is now running with:
- ✅ 5 API endpoints working
- ✅ Auto-classification enabled
- ✅ Database connected
- ✅ Interactive documentation available

---

## Next Steps

### Option 1: Test the API (5 minutes)
- Use Swagger docs at http://localhost:8000/docs
- Try creating, listing, updating, deleting tasks
- See auto-classification in action!

### Option 2: Install Flutter (10 minutes)
```bash
brew install --cask flutter
cd ../flutter_app
flutter pub get
flutter run
```

### Option 3: Deploy to Production (10 minutes)
1. Go to https://render.com
2. Create account
3. New Web Service → Connect GitHub
4. Root directory: `backend`
5. Build: `pip install -r requirements.txt`
6. Start: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`
7. Add environment variables (same as .env)
8. Deploy!

---

## 🆘 Troubleshooting

### "Connection refused"
- Make sure backend server is running
- Check terminal for errors

### "Authentication error"
- Verify SUPABASE_URL and SUPABASE_KEY in .env
- Make sure you copied the FULL values

### "Module not found"
- Virtual environment activated? (`source venv/bin/activate`)
- Dependencies installed? (`pip install -r requirements.txt`)

### "Table does not exist"
- Did schema.sql run successfully in Supabase?
- Check Supabase → Table Editor → should see `tasks` and `task_history`

---

## 📞 Quick Commands Reference

```bash
# Start backend
cd backend
source venv/bin/activate
python -m uvicorn src.main:app --reload

# Run tests
pytest tests/ -v

# Install Flutter
brew install --cask flutter

# Run Flutter app
cd flutter_app
flutter pub get
flutter run

# Stop server
Press Ctrl+C in terminal
```

---

That's it! You're ready to go! 🚀
