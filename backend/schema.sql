-- Smart Task Manager Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT CHECK (category IN ('scheduling', 'finance', 'technical', 'safety', 'general')),
  priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
  status TEXT CHECK (status IN ('pending', 'in_progress', 'completed')) DEFAULT 'pending',
  assigned_to TEXT,
  due_date TIMESTAMPTZ,
  extracted_entities JSONB DEFAULT '{}',
  suggested_actions JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create task_history table
CREATE TABLE IF NOT EXISTS task_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  action TEXT CHECK (action IN ('created', 'updated', 'status_changed', 'completed')),
  old_value JSONB,
  new_value JSONB,
  changed_by TEXT,
  changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_category ON tasks(category);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_task_history_task_id ON task_history(task_id);
CREATE INDEX IF NOT EXISTS idx_task_history_changed_at ON task_history(changed_at DESC);

-- Create function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing (optional)
INSERT INTO tasks (title, description, category, priority, status, assigned_to, due_date, extracted_entities, suggested_actions)
VALUES 
  (
    'Schedule team meeting',
    'Arrange urgent meeting with team tomorrow to discuss budget allocation',
    'scheduling',
    'high',
    'pending',
    'John Doe',
    NOW() + INTERVAL '1 day',
    '{"dates": ["tomorrow"], "people": ["team"], "actions": ["Schedule", "discuss"]}'::jsonb,
    '["Block calendar time", "Send meeting invite", "Prepare meeting agenda"]'::jsonb
  ),
  (
    'Fix payment system bug',
    'Critical error in payment processing needs immediate fix',
    'technical',
    'high',
    'in_progress',
    'Jane Smith',
    NOW() + INTERVAL '2 hours',
    '{"dates": [], "people": [], "actions": ["Fix"]}'::jsonb,
    '["Diagnose the issue", "Check system resources", "Assign to technician"]'::jsonb
  ),
  (
    'Review budget report',
    'Check Q4 financial records and update budget documentation',
    'finance',
    'medium',
    'pending',
    'Bob Johnson',
    NOW() + INTERVAL '1 week',
    '{"dates": [], "people": [], "actions": ["Review", "Check", "update"]}'::jsonb,
    '["Check budget availability", "Get approval from manager", "Update financial records"]'::jsonb
  );

-- Display success message
SELECT 'Database schema created successfully! Tables: tasks, task_history' AS message;
