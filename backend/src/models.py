from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class TaskCategory(str, Enum):
    """Task category enum."""
    SCHEDULING = "scheduling"
    FINANCE = "finance"
    TECHNICAL = "technical"
    SAFETY = "safety"
    GENERAL = "general"


class TaskPriority(str, Enum):
    """Task priority enum."""
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class TaskStatus(str, Enum):
    """Task status enum."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class TaskAction(str, Enum):
    """Task history action enum."""
    CREATED = "created"
    UPDATED = "updated"
    STATUS_CHANGED = "status_changed"
    COMPLETED = "completed"


# Request Models
class CreateTaskRequest(BaseModel):
    """Request model for creating a task."""
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1, max_length=2000)
    assigned_to: Optional[str] = Field(None, max_length=100)
    due_date: Optional[datetime] = None
    
    @field_validator('title', 'description')
    @classmethod
    def validate_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('Field cannot be empty or whitespace only')
        return v.strip()


class UpdateTaskRequest(BaseModel):
    """Request model for updating a task."""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, min_length=1, max_length=2000)
    category: Optional[TaskCategory] = None
    priority: Optional[TaskPriority] = None
    status: Optional[TaskStatus] = None
    assigned_to: Optional[str] = Field(None, max_length=100)
    due_date: Optional[datetime] = None


# Response Models
class ExtractedEntities(BaseModel):
    """Extracted entities from task content."""
    dates: List[str] = Field(default_factory=list)
    people: List[str] = Field(default_factory=list)
    locations: List[str] = Field(default_factory=list)
    actions: List[str] = Field(default_factory=list)


class Task(BaseModel):
    """Task response model."""
    id: str
    title: str
    description: str
    category: TaskCategory
    priority: TaskPriority
    status: TaskStatus
    assigned_to: Optional[str] = None
    due_date: Optional[datetime] = None
    extracted_entities: ExtractedEntities
    suggested_actions: List[str]
    created_at: datetime
    updated_at: datetime


class TaskHistory(BaseModel):
    """Task history response model."""
    id: str
    task_id: str
    action: TaskAction
    old_value: Optional[Dict[str, Any]] = None
    new_value: Optional[Dict[str, Any]] = None
    changed_by: Optional[str] = None
    changed_at: datetime


class TaskWithHistory(BaseModel):
    """Task with complete history."""
    task: Task
    history: List[TaskHistory]


class TaskListResponse(BaseModel):
    """Paginated task list response."""
    tasks: List[Task]
    total: int
    limit: int
    offset: int
    has_more: bool


class DeleteTaskResponse(BaseModel):
    """Delete task response."""
    message: str
    task_id: str


class ErrorResponse(BaseModel):
    """Error response model."""
    error: str
    details: Optional[List[Dict[str, str]]] = None
    status: int
