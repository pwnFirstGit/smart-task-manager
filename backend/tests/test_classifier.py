"""
Unit tests for the task classification engine.
"""
import pytest
from datetime import datetime, timedelta
from src.classifier import TaskClassifier
from src.models import TaskCategory, TaskPriority


@pytest.fixture
def classifier():
    """Create a classifier instance for testing."""
    return TaskClassifier()


class TestCategoryClassification:
    """Test category detection logic."""
    
    def test_scheduling_category(self, classifier):
        """Test that scheduling keywords are correctly identified."""
        title = "Schedule urgent meeting"
        description = "Need to arrange a call with the team tomorrow"
        
        category, _, _, _ = classifier.classify(title, description)
        
        assert category == TaskCategory.SCHEDULING
    
    def test_finance_category(self, classifier):
        """Test that finance keywords are correctly identified."""
        title = "Process invoice payment"
        description = "Pay the outstanding bill for Q4 budget"
        
        category, _, _, _ = classifier.classify(title, description)
        
        assert category == TaskCategory.FINANCE
    
    def test_technical_category(self, classifier):
        """Test that technical keywords are correctly identified."""
        title = "Fix critical bug"
        description = "System error needs urgent repair and debugging"
        
        category, _, _, _ = classifier.classify(title, description)
        
        assert category == TaskCategory.TECHNICAL
    
    def test_safety_category(self, classifier):
        """Test that safety keywords are correctly identified."""
        title = "Safety inspection needed"
        description = "Conduct hazard assessment and compliance check"
        
        category, _, _, _ = classifier.classify(title, description)
        
        assert category == TaskCategory.SAFETY
    
    def test_general_category_default(self, classifier):
        """Test that general category is assigned for unknown keywords."""
        title = "Random task"
        description = "Some general work to be done"
        
        category, _, _, _ = classifier.classify(title, description)
        
        assert category == TaskCategory.GENERAL


class TestPriorityAssignment:
    """Test priority assignment logic."""
    
    def test_high_priority_urgent_keyword(self, classifier):
        """Test that urgent keywords trigger high priority."""
        title = "Urgent: Fix immediately"
        description = "Critical issue that needs ASAP attention"
        
        _, priority, _, _ = classifier.classify(title, description)
        
        assert priority == TaskPriority.HIGH
    
    def test_high_priority_due_today(self, classifier):
        """Test that tasks due within 24 hours are high priority."""
        title = "Complete report"
        description = "Regular task"
        due_date = datetime.now() + timedelta(hours=12)
        
        _, priority, _, _ = classifier.classify(title, description, due_date)
        
        assert priority == TaskPriority.HIGH
    
    def test_medium_priority_this_week(self, classifier):
        """Test that 'this week' triggers medium priority."""
        title = "Complete this week"
        description = "Important task for the week"
        
        _, priority, _, _ = classifier.classify(title, description)
        
        assert priority == TaskPriority.MEDIUM
    
    def test_medium_priority_due_this_week(self, classifier):
        """Test that tasks due within 7 days are medium priority."""
        title = "Regular task"
        description = "Normal work"
        due_date = datetime.now() + timedelta(days=5)
        
        _, priority, _, _ = classifier.classify(title, description, due_date)
        
        assert priority == TaskPriority.MEDIUM
    
    def test_low_priority_default(self, classifier):
        """Test that low priority is the default."""
        title = "Future enhancement"
        description = "Can be done later when possible"
        
        _, priority, _, _ = classifier.classify(title, description)
        
        assert priority == TaskPriority.LOW


class TestEntityExtraction:
    """Test entity extraction logic."""
    
    def test_extract_dates(self, classifier):
        """Test that date references are extracted."""
        title = "Meeting tomorrow"
        description = "Schedule for next week on Friday"
        
        _, _, entities, _ = classifier.classify(title, description)
        
        assert "tomorrow" in entities.dates
        assert any("week" in date.lower() for date in entities.dates)
    
    def test_extract_people(self, classifier):
        """Test that person names are extracted."""
        title = "Meet with John"
        description = "Discuss budget with Sarah and assign to Mike"
        
        _, _, entities, _ = classifier.classify(title, description)
        
        assert "John" in entities.people
        assert "Sarah" in entities.people
        assert "Mike" in entities.people
    
    def test_extract_actions(self, classifier):
        """Test that action verbs are extracted."""
        title = "Schedule and prepare"
        description = "Review the document and send to team"
        
        _, _, entities, _ = classifier.classify(title, description)
        
        # At least some action verbs should be found
        assert len(entities.actions) > 0
        assert any(action.lower() in ["schedule", "prepare", "review", "send"] 
                  for action in entities.actions)
    
    def test_entity_extraction_empty_case(self, classifier):
        """Test entity extraction with minimal text."""
        title = "Task"
        description = "Do work"
        
        _, _, entities, _ = classifier.classify(title, description)
        
        # Should not crash, should return valid (possibly empty) entities
        assert isinstance(entities.dates, list)
        assert isinstance(entities.people, list)
        assert isinstance(entities.actions, list)


class TestSuggestedActions:
    """Test suggested actions generation."""
    
    def test_scheduling_actions(self, classifier):
        """Test that scheduling tasks get appropriate actions."""
        title = "Schedule meeting"
        description = "Arrange team call"
        
        _, _, _, actions = classifier.classify(title, description)
        
        assert len(actions) > 0
        assert any("calendar" in action.lower() or "invite" in action.lower() 
                  for action in actions)
    
    def test_finance_actions(self, classifier):
        """Test that finance tasks get appropriate actions."""
        title = "Process payment"
        description = "Pay invoice for budget"
        
        _, _, _, actions = classifier.classify(title, description)
        
        assert len(actions) > 0
        assert any("budget" in action.lower() or "invoice" in action.lower() 
                  for action in actions)
    
    def test_technical_actions(self, classifier):
        """Test that technical tasks get appropriate actions."""
        title = "Fix bug"
        description = "Debug system error"
        
        _, _, _, actions = classifier.classify(title, description)
        
        assert len(actions) > 0
        assert any("diagnose" in action.lower() or "technician" in action.lower() 
                  for action in actions)
