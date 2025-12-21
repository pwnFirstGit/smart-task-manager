"""
Auto-classification engine for tasks.
Implements category detection, priority assignment, entity extraction, and action suggestions.
"""
import re
from typing import Dict, List, Tuple
from datetime import datetime, timedelta
from .models import TaskCategory, TaskPriority, ExtractedEntities


class TaskClassifier:
    """Classifies tasks based on content analysis."""
    
    # Category keywords
    CATEGORY_KEYWORDS = {
        TaskCategory.SCHEDULING: [
            'meeting', 'schedule', 'call', 'appointment', 'deadline', 
            'calendar', 'book', 'arrange', 'plan', 'organize'
        ],
        TaskCategory.FINANCE: [
            'payment', 'invoice', 'bill', 'budget', 'cost', 'expense',
            'purchase', 'financial', 'money', 'pay', 'pricing'
        ],
        TaskCategory.TECHNICAL: [
            'bug', 'fix', 'error', 'install', 'repair', 'maintain',
            'update', 'debug', 'code', 'system', 'software', 'hardware'
        ],
        TaskCategory.SAFETY: [
            'safety', 'hazard', 'inspection', 'compliance', 'ppe',
            'risk', 'incident', 'emergency', 'secure', 'protocol'
        ]
    }
    
    # Priority keywords
    PRIORITY_KEYWORDS = {
        TaskPriority.HIGH: [
            'urgent', 'asap', 'immediately', 'today', 'critical',
            'emergency', 'now', 'deadline'
        ],
        TaskPriority.MEDIUM: [
            'soon', 'this week', 'important', 'priority', 'upcoming'
        ]
    }
    
    # Suggested actions by category
    SUGGESTED_ACTIONS = {
        TaskCategory.SCHEDULING: [
            "Block calendar time",
            "Send meeting invite",
            "Prepare meeting agenda",
            "Set reminder notification"
        ],
        TaskCategory.FINANCE: [
            "Check budget availability",
            "Get approval from manager",
            "Generate invoice",
            "Update financial records"
        ],
        TaskCategory.TECHNICAL: [
            "Diagnose the issue",
            "Check system resources",
            "Assign to technician",
            "Document the fix"
        ],
        TaskCategory.SAFETY: [
            "Conduct safety inspection",
            "File incident report",
            "Notify safety supervisor",
            "Update safety checklist"
        ],
        TaskCategory.GENERAL: [
            "Review task details",
            "Gather required information",
            "Create action plan",
            "Track progress"
        ]
    }
    
    def classify(
        self, 
        title: str, 
        description: str, 
        due_date: datetime = None
    ) -> Tuple[TaskCategory, TaskPriority, ExtractedEntities, List[str]]:
        """
        Classify a task and extract relevant information.
        
        Args:
            title: Task title
            description: Task description
            due_date: Optional due date
            
        Returns:
            Tuple of (category, priority, entities, suggested_actions)
        """
        combined_text = f"{title} {description}".lower()
        
        category = self._detect_category(combined_text)
        priority = self._assign_priority(combined_text, due_date)
        entities = self._extract_entities(title, description)
        actions = self.SUGGESTED_ACTIONS[category]
        
        return category, priority, entities, actions
    
    def _detect_category(self, text: str) -> TaskCategory:
        """Detect task category based on keyword matching."""
        category_scores = {}
        
        for category, keywords in self.CATEGORY_KEYWORDS.items():
            score = sum(1 for keyword in keywords if keyword in text)
            category_scores[category] = score
        
        # Get category with highest score
        max_score = max(category_scores.values())
        
        if max_score == 0:
            return TaskCategory.GENERAL
        
        # Return first category with max score
        for category, score in category_scores.items():
            if score == max_score:
                return category
        
        return TaskCategory.GENERAL
    
    def _assign_priority(self, text: str, due_date: datetime = None) -> TaskPriority:
        """Assign priority based on urgency indicators and due date."""
        # Check for high priority keywords
        for keyword in self.PRIORITY_KEYWORDS[TaskPriority.HIGH]:
            if keyword in text:
                return TaskPriority.HIGH
        
        # Check due date proximity
        if due_date:
            time_until_due = due_date - datetime.now()
            
            if time_until_due <= timedelta(days=1):
                return TaskPriority.HIGH
            elif time_until_due <= timedelta(days=7):
                return TaskPriority.MEDIUM
        
        # Check for medium priority keywords
        for keyword in self.PRIORITY_KEYWORDS[TaskPriority.MEDIUM]:
            if keyword in text:
                return TaskPriority.MEDIUM
        
        return TaskPriority.LOW
    
    def _extract_entities(self, title: str, description: str) -> ExtractedEntities:
        """Extract entities from task content."""
        combined_text = f"{title} {description}"
        
        dates = self._extract_dates(combined_text)
        people = self._extract_people(combined_text)
        locations = self._extract_locations(combined_text)
        actions = self._extract_actions(title, description)
        
        return ExtractedEntities(
            dates=dates,
            people=people,
            locations=locations,
            actions=actions
        )
    
    def _extract_dates(self, text: str) -> List[str]:
        """Extract date references from text."""
        dates = []
        
        # Common date patterns
        date_patterns = [
            r'\btoday\b', r'\btomorrow\b', r'\byesterday\b',
            r'\bthis week\b', r'\bnext week\b', r'\bthis month\b',
            r'\bmonday\b', r'\btuesday\b', r'\bwednesday\b', r'\bthursday\b',
            r'\bfriday\b', r'\bsaturday\b', r'\bsunday\b',
            r'\d{1,2}/\d{1,2}/\d{2,4}',  # Date format: 12/31/2024
            r'\d{1,2}-\d{1,2}-\d{2,4}',  # Date format: 12-31-2024
            r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2}\b'
        ]
        
        for pattern in date_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            dates.extend(matches)
        
        return list(set(dates))  # Remove duplicates
    
    def _extract_people(self, text: str) -> List[str]:
        """Extract person names from text."""
        people = []
        
        # Pattern: "with/by/assign to [Name]" - improved to stop at word boundaries
        name_patterns = [
            r'\bwith\s+([A-Z][a-z]+)',
            r'\bby\s+([A-Z][a-z]+)',
            r'\bassign\s+to\s+([A-Z][a-z]+)',
            r'\bfor\s+([A-Z][a-z]+)'
        ]
        
        for pattern in name_patterns:
            matches = re.findall(pattern, text)
            people.extend(matches)
        
        return list(set(people))  # Remove duplicates
    
    def _extract_locations(self, text: str) -> List[str]:
        """Extract location references from text."""
        locations = []
        
        # Pattern: "at/in [Location]"
        location_patterns = [
            r'\bat\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
            r'\bin\s+(?:the\s+)?([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
            r'(?:Room|Office|Building)\s+(\w+)',
        ]
        
        for pattern in location_patterns:
            matches = re.findall(pattern, text)
            locations.extend(matches)
        
        return list(set(locations))  # Remove duplicates
    
    def _extract_actions(self, title: str, description: str) -> List[str]:
        """Extract action verbs from text."""
        actions = []
        
        # Common action verbs
        action_verbs = [
            'schedule', 'send', 'prepare', 'review', 'check', 'create',
            'update', 'fix', 'install', 'complete', 'submit', 'approve',
            'assign', 'notify', 'conduct', 'generate', 'document'
        ]
        
        combined_text = f"{title} {description}".lower()
        
        for verb in action_verbs:
            if verb in combined_text:
                actions.append(verb.capitalize())
        
        return list(set(actions))  # Remove duplicates


# Global classifier instance
classifier = TaskClassifier()
