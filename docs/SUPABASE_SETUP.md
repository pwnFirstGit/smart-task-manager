# Supabase Setup Guide

## Step 1: Create Supabase Account

1. Go to **https://supabase.com**
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email
4. Verify your email if required

## Step 2: Create New Project

1. Once logged in, click "New Project"
2. Fill in the details:
   - **Name**: `smart-task-manager` (or any name you like)
   - **Database Password**: Create a strong password and **save it**
   - **Region**: Choose closest to you
   - **Pricing Plan**: Free tier is perfect for this project
3. Click "Create new project"
4. Wait 1-2 minutes for setup to complete

## Step 3: Run Database Schema

1. Once your project is ready, click on "SQL Editor" in the left sidebar (SQL icon)
2. Click "New query"
3. Open the file `backend/schema.sql` from this project
4. Copy ALL the contents
5. Paste into the Supabase SQL Editor
6. Click "Run" (or press Cmd+Enter)
7. You should see "Database schema created successfully!"

## Step 4: Get Your API Credentials

1. Click on "Settings" (gear icon) in the left sidebar
2. Click on "API" in the settings menu
3. You'll see two important values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (long string under "Project API keys")
4. **IMPORTANT**: Copy both of these values

## Step 5: Configure Backend Environment

1. Open `backend/.env` file in your code editor
2. Replace the placeholder values:
   ```
   SUPABASE_URL=https://xxxxx.supabase.co  # Paste your Project URL
   SUPABASE_KEY=eyJxxx...  # Paste your anon public key
   PORT=8000
   ENVIRONMENT=development
   ```
3. Save the file

## Step 6: Verify Setup

You can verify your database is set up correctly:

1. In Supabase, go to "Table Editor" in the left sidebar
2. You should see two tables:
   - ✅ **tasks** (with 3 sample rows)
   - ✅ **task_history** (empty initially)
3. Click on "tasks" to see the sample data

## Troubleshooting

**Issue**: Can't see tables after running schema
- **Solution**: Make sure you clicked "Run" in the SQL Editor
- Check for any error messages in red
- Try refreshing the page

**Issue**: SQL query fails
- **Solution**: Make sure you copied the ENTIRE contents of schema.sql
- The file should start with `-- Smart Task Manager Database Schema`

## Next Steps

Once you've completed the above steps:
1. Your backend `.env` file should have the real Supabase credentials
2. You can start the backend server with `python -m uvicorn src.main:app --reload`
3. The API will connect to your Supabase database

---

**Need help?** Let me know which step you're stuck on!
