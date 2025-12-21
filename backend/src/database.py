"""
Database service for interacting with Supabase.
"""
from typing import List, Optional, Dict, Any
from datetime import datetime
from supabase import create_client, Client
from .config import get_settings
from .models import (
    Task, TaskHistory, TaskCategory, TaskPriority, 
    TaskStatus, TaskAction, ExtractedEntities, CreateTaskRequest,
    UpdateTaskRequest
)
from .classifier import classifier


class DatabaseService:
    """Service for database operations."""
    
    def __init__(self):
        """Initialize Supabase client."""
        settings = get_settings()
        self.client: Client = create_client(
            settings.supabase_url,
            settings.supabase_key
        )
    
    async def create_task(
        self, 
        task_data: CreateTaskRequest,
        changed_by: str = "system"
    ) -> Task:
        """
        Create a new task with auto-classification.
        
        Args:
            task_data: Task creation data
            changed_by: User who created the task
            
        Returns:
            Created task with classification
        """
        # Run auto-classification
        category, priority, entities, actions = classifier.classify(
            task_data.title,
            task_data.description,
            task_data.due_date
        )
        
        # Prepare task data
        task_dict = {
            "title": task_data.title,
            "description": task_data.description,
            "category": category.value,
            "priority": priority.value,
            "status": TaskStatus.PENDING.value,
            "assigned_to": task_data.assigned_to,
            "due_date": task_data.due_date.isoformat() if task_data.due_date else None,
            "extracted_entities": entities.model_dump(),
            "suggested_actions": actions,
        }
        
        # Insert task
        result = self.client.table("tasks").insert(task_dict).execute()
        
        if not result.data:
            raise Exception("Failed to create task")
        
        task_record = result.data[0]
        
        # Log to history
        await self._log_history(
            task_id=task_record["id"],
            action=TaskAction.CREATED,
            new_value=task_record,
            changed_by=changed_by
        )
        
        return self._parse_task(task_record)
    
    async def get_tasks(
        self,
        status: Optional[TaskStatus] = None,
        category: Optional[TaskCategory] = None,
        priority: Optional[TaskPriority] = None,
        search: Optional[str] = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
        limit: int = 20,
        offset: int = 0
    ) -> tuple[List[Task], int]:
        """
        Get tasks with filtering, sorting, and pagination.
        
        Returns:
            Tuple of (tasks, total_count)
        """
        # Build query
        query = self.client.table("tasks").select("*", count="exact")
        
        # Apply filters
        if status:
            query = query.eq("status", status.value)
        if category:
            query = query.eq("category", category.value)
        if priority:
            query = query.eq("priority", priority.value)
        if search:
            query = query.or_(
                f"title.ilike.%{search}%,description.ilike.%{search}%"
            )
        
        # Apply sorting
        query = query.order(sort_by, desc=(sort_order == "desc"))
        
        # Apply pagination
        query = query.range(offset, offset + limit - 1)
        
        # Execute query
        result = query.execute()
        
        tasks = [self._parse_task(record) for record in result.data]
        total = result.count or 0
        
        return tasks, total
    
    async def get_task(self, task_id: str) -> Optional[Task]:
        """Get a single task by ID."""
        result = self.client.table("tasks").select("*").eq("id", task_id).execute()
        
        if not result.data:
            return None
        
        return self._parse_task(result.data[0])
    
    async def get_task_history(self, task_id: str) -> List[TaskHistory]:
        """Get task history."""
        result = (
            self.client.table("task_history")
            .select("*")
            .eq("task_id", task_id)
            .order("changed_at", desc=True)
            .execute()
        )
        
        return [self._parse_history(record) for record in result.data]
    
    async def update_task(
        self,
        task_id: str,
        update_data: UpdateTaskRequest,
        changed_by: str = "system"
    ) -> Optional[Task]:
        """Update a task."""
        # Get current task
        current_task = await self.get_task(task_id)
        if not current_task:
            return None
        
        # Prepare update data
        update_dict = {}
        if update_data.title is not None:
            update_dict["title"] = update_data.title
        if update_data.description is not None:
            update_dict["description"] = update_data.description
        if update_data.category is not None:
            update_dict["category"] = update_data.category.value
        if update_data.priority is not None:
            update_dict["priority"] = update_data.priority.value
        if update_data.status is not None:
            update_dict["status"] = update_data.status.value
        if update_data.assigned_to is not None:
            update_dict["assigned_to"] = update_data.assigned_to
        if update_data.due_date is not None:
            update_dict["due_date"] = update_data.due_date.isoformat()
        
        if not update_dict:
            return current_task
        
        # Update task
        result = (
            self.client.table("tasks")
            .update(update_dict)
            .eq("id", task_id)
            .execute()
        )
        
        if not result.data:
            return None
        
        updated_task = result.data[0]
        
        # Determine action type
        action = TaskAction.UPDATED
        if update_data.status and update_data.status != current_task.status:
            if update_data.status == TaskStatus.COMPLETED:
                action = TaskAction.COMPLETED
            else:
                action = TaskAction.STATUS_CHANGED
        
        # Log to history
        await self._log_history(
            task_id=task_id,
            action=action,
            old_value=current_task.model_dump(),
            new_value=updated_task,
            changed_by=changed_by
        )
        
        return self._parse_task(updated_task)
    
    async def delete_task(self, task_id: str) -> bool:
        """Delete a task."""
        result = self.client.table("tasks").delete().eq("id", task_id).execute()
        return len(result.data) > 0
    
    async def _log_history(
        self,
        task_id: str,
        action: TaskAction,
        old_value: Optional[Dict[str, Any]] = None,
        new_value: Optional[Dict[str, Any]] = None,
        changed_by: str = "system"
    ):
        """Log task change to history."""
        history_dict = {
            "task_id": task_id,
            "action": action.value,
            "old_value": old_value,
            "new_value": new_value,
            "changed_by": changed_by
        }
        
        self.client.table("task_history").insert(history_dict).execute()
    
    def _parse_task(self, record: Dict[str, Any]) -> Task:
        """Parse task record from database."""
        return Task(
            id=record["id"],
            title=record["title"],
            description=record["description"],
            category=TaskCategory(record["category"]),
            priority=TaskPriority(record["priority"]),
            status=TaskStatus(record["status"]),
            assigned_to=record.get("assigned_to"),
            due_date=datetime.fromisoformat(record["due_date"]) if record.get("due_date") else None,
            extracted_entities=ExtractedEntities(**record.get("extracted_entities", {})),
            suggested_actions=record.get("suggested_actions", []),
            created_at=datetime.fromisoformat(record["created_at"]),
            updated_at=datetime.fromisoformat(record["updated_at"])
        )
    
    def _parse_history(self, record: Dict[str, Any]) -> TaskHistory:
        """Parse task history record from database."""
        return TaskHistory(
            id=record["id"],
            task_id=record["task_id"],
            action=TaskAction(record["action"]),
            old_value=record.get("old_value"),
            new_value=record.get("new_value"),
            changed_by=record.get("changed_by"),
            changed_at=datetime.fromisoformat(record["changed_at"])
        )


# Global database service instance
db_service = DatabaseService()
