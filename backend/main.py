from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any
import os
from dotenv import load_dotenv
import logging

# Comment out the GreetingAgent import for initial testing
# from agents import GreetingAgent

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Comment out the GreetingAgent initialization for initial testing
# greeting_agent = GreetingAgent()

# Initialize FastAPI app
app = FastAPI(
    title="Music Besties API",
    description="Backend API for The Music Besties application",
    version="0.1.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request models
class ChatMessage(BaseModel):
    message: str

class NameSubmission(BaseModel):
    name: str

# Response models
class ChatResponse(BaseModel):
    message: str
    component_trigger: Optional[Dict[str, Any]] = None

class ComponentTrigger(BaseModel):
    component_type: str
    data: Dict[str, Any]

# Routes
@app.get("/")
async def root():
    return {"status": "ok", "message": "Music Besties API is running"}

@app.post("/api/chat", response_model=ChatResponse)
async def chat(chat_message: ChatMessage):
    """
    Process a chat message from the user and return an AI response.
    In Phase 0, this is a simple greeting flow.
    """
    user_message = chat_message.message.lower()
    
    # Simple greeting detection
    greetings = ["hello", "hi", "hey", "greetings", "howdy"]
    if any(greeting in user_message for greeting in greetings):
        # Simplified response for initial testing
        return ChatResponse(
            message="I'd like to get to know you better. What's your name?",
            component_trigger={
                "component_type": "name_input_form",
                "data": {
                    "title": "Tell me about yourself",
                    "description": "To personalize your experience, I need to know a bit about you.",
                    "label": "Your First Name",
                    "placeholder": "Enter your name"
                }
            }
        )
    else:
        # Default response
        return ChatResponse(
            message="I'm your AI concierge. To get started, just say hello!"
        )

@app.post("/api/ui/component-trigger")
async def component_trigger(trigger: ComponentTrigger):
    """
    Internal endpoint for CrewAI agents to trigger UI components.
    """
    # This would normally validate and process the trigger
    # For Phase 0, we'll just return the trigger data
    return trigger

@app.post("/api/submit-name", response_model=ChatResponse)
async def submit_name(submission: NameSubmission):
    """
    Process a name submission from the user and return a personalized response.
    """
    name = submission.name
    
    # In a real implementation, this would store the name in a database
    
    # Simplified response for initial testing
    return ChatResponse(
        message=f"Nice to meet you, {name}! I've prepared a welcome message for you in the sideboard.",
        component_trigger={
            "component_type": "sideboard_welcome_display",
            "data": {
                "name": name
            }
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
