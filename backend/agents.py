from crewai import Agent, Task, Crew
from typing import Dict, Any, Optional
import logging

# Configure logging
logger = logging.getLogger(__name__)

class UITools:
    """
    Tools for CrewAI agents to interact with the frontend UI
    """
    
    @staticmethod
    def contextual_input_module(
        title: str,
        label: str,
        input_type: str = "text",
        description: Optional[str] = None,
        placeholder: Optional[str] = None,
        required: bool = True,
        submit_button_text: str = "Save"
    ) -> Dict[str, Any]:
        """
        Tool to trigger a contextual input module in the frontend
        """
        logger.info(f"Triggering contextual input module: {title}")
        return {
            "component_type": "contextual_input_module",
            "data": {
                "title": title,
                "description": description,
                "input_type": input_type,
                "label": label,
                "placeholder": placeholder,
                "required": required,
                "submit_button_text": submit_button_text
            }
        }
    
    @staticmethod
    def sideboard_display(
        component_type: str,
        data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Tool to trigger content display in the sideboard
        """
        logger.info(f"Triggering sideboard display: {component_type}")
        return {
            "component_type": component_type,
            "data": data
        }

class GreetingAgent:
    """
    Agent responsible for greeting users and collecting basic information
    """
    
    def __init__(self):
        self.tools = UITools()
        self.agent = Agent(
            role="The primary greeter and initial guide",
            goal="To warmly welcome the user, introduce the app's functionality, and obtain their basic identity (name) to personalize the interaction",
            backstory="You are the friendly AI concierge for Music Besties, an app that helps users find their music tribe. Your job is to make users feel welcome and guide them through their first interaction.",
            verbose=True,
            allow_delegation=False
        )
    
    def greet_user_and_ask_name(self, user_message: str) -> Dict[str, Any]:
        """
        Greet the user and ask for their name using a contextual input module
        """
        # In a real implementation, this would use the CrewAI agent's LLM to generate a response
        # For Phase 0, we'll use a hardcoded response
        
        response = {
            "message": "I'd like to get to know you better. What's your name?",
            "component_trigger": self.tools.contextual_input_module(
                title="Tell me about yourself",
                description="To personalize your experience, I need to know a bit about you.",
                label="Your First Name",
                placeholder="Enter your name"
            )
        }
        
        return response
    
    def process_name_and_welcome(self, name: str) -> Dict[str, Any]:
        """
        Process the user's name and welcome them with a sideboard display
        """
        # In a real implementation, this would use the CrewAI agent's LLM to generate a response
        # For Phase 0, we'll use a hardcoded response
        
        response = {
            "message": f"Nice to meet you, {name}! I've prepared a welcome message for you in the sideboard.",
            "component_trigger": self.tools.sideboard_display(
                component_type="sideboard_welcome_display",
                data={"name": name}
            )
        }
        
        return response
