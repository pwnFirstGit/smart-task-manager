"""
FastAPI application with task management endpoints.
"""
from fastapi import FastAPI, HTTPException, Query, Path
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from .models import (
    CreateTaskRequest, UpdateTaskRequest, Task, TaskWithHistory,
    TaskListResponse, DeleteTaskResponse, TaskStatus, TaskCategory,
    TaskPriority, ErrorResponse
)
from .database import db_service
from .config import get_settings

# Create FastAPI app
app = FastAPI(
    title="Smart Task Manager API",
    description="Task management system with auto-classification",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    """Health check endpoint."""
    return {
        "message": "Smart Task Manager API",
        "status": "running",
        "version": "1.0.0"
    }


@app.post(
    "/api/tasks",
    response_model=Task,
    status_code=201,
    responses={
        400: {"model": ErrorResponse, "description": "Validation error"}
    }
)
async def create_task(task_data: CreateTaskRequest):
    """
    Create a new task with automatic classification.
    
    The system will automatically:
    - Detect category based on keywords
    - Assign priority based on urgency indicators
    - Extract entities (dates, people, locations, actions)
    - Generate suggested actions
    """
    try:
        task = await db_service.create_task(task_data)
        return task
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create task: {str(e)}"
        )


@app.get(
    "/api/tasks",
    response_model=TaskListResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid parameters"}
    }
)
async def list_tasks(
    status: Optional[TaskStatus] = Query(None, description="Filter by status"),
    category: Optional[TaskCategory] = Query(None, description="Filter by category"),
    priority: Optional[TaskPriority] = Query(None, description="Filter by priority"),
    search: Optional[str] = Query(None, description="Search in title and description"),
    sort_by: str = Query("created_at", description="Field to sort by"),
    sort_order: str = Query("desc", regex="^(asc|desc)$", description="Sort order"),
    limit: int = Query(20, ge=1, le=100, description="Number of items to return"),
    offset: int = Query(0, ge=0, description="Number of items to skip")
):
    """
    List all tasks with filtering, sorting, and pagination.
    
    Supports:
    - Filtering by status, category, priority
    - Text search in title and description
    - Sorting by any field
    - Pagination with limit and offset
    """
    try:
        tasks, total = await db_service.get_tasks(
            status=status,
            category=category,
            priority=priority,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order,
            limit=limit,
            offset=offset
        )
        
        has_more = (offset + limit) < total
        
        return TaskListResponse(
            tasks=tasks,
            total=total,
            limit=limit,
            offset=offset,
            has_more=has_more
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch tasks: {str(e)}"
        )


@app.get(
    "/api/tasks/{task_id}",
    response_model=TaskWithHistory,
    responses={
        404: {"model": ErrorResponse, "description": "Task not found"}
    }
)
async def get_task(
    task_id: str = Path(..., description="Task ID")
):
    """
    Get a single task by ID with complete history.
    
    Returns the task details along with all historical changes.
    """
    task = await db_service.get_task(task_id)
    
    if not task:
        raise HTTPException(
            status_code=404,
            detail=f"Task not found: {task_id}"
        )
    
    history = await db_service.get_task_history(task_id)
    
    return TaskWithHistory(task=task, history=history)


@app.patch(
    "/api/tasks/{task_id}",
    response_model=Task,
    responses={
        404: {"model": ErrorResponse, "description": "Task not found"},
        400: {"model": ErrorResponse, "description": "Validation error"}
    }
)
async def update_task(
    update_data: UpdateTaskRequest,
    task_id: str = Path(..., description="Task ID")
):
    """
    Update a task.
    
    Supports partial updates - only send the fields you want to change.
    All changes are logged in the task history.
    """
    try:
        task = await db_service.update_task(task_id, update_data)
        
        if not task:
            raise HTTPException(
                status_code=404,
                detail=f"Task not found: {task_id}"
            )
        
        return task
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update task: {str(e)}"
        )


@app.delete(
    "/api/tasks/{task_id}",
    response_model=DeleteTaskResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Task not found"}
    }
)
async def delete_task(
    task_id: str = Path(..., description="Task ID")
):
    """
    Delete a task.
    
    This will also delete all associated history records (cascade delete).
    """
    success = await db_service.delete_task(task_id)
    
    if not success:
        raise HTTPException(
            status_code=404,
            detail=f"Task not found: {task_id}"
        )
    
    return DeleteTaskResponse(
        message="Task deleted successfully",
        task_id=task_id
    )


if __name__ == "__main__":
    import uvicorn
    settings = get_settings()
    uvicorn.run(app, host="0.0.0.0", port=settings.port)
